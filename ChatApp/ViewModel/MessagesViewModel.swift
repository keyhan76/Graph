//
//  MessagesViewModel.swift
//  ChatApp
//
//  Created by Keyhan on 12/13/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Foundation
import Firebase

class MessagesViewModel {
    
    // MARK: - Private Variables
    private weak var delegate: MessagesViewModelDelegate?
    private var isFetchInProgress = false
    private var messages: [Message] = []
    private var chatId: String?
    
    // MARK: - Public Varibles
    public var totalCount: Int {
        return messages.count
    }
    
    // MARK: - Initializer
    init(delegate: MessagesViewModelDelegate, chatId: String?) {
        self.delegate = delegate
        self.chatId = chatId
    }
    
    // MARK: - Helprs
    func message(at index: Int) -> Message {
        return messages[index]
    }
    
    // MARK: - Private Helpers
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        guard message.chatId == chatId else {
            self.delegate?.onFetchFailed(with: "No messages yet...", errorType: nil)
            return
        }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        // Notify the delegate
        self.delegate?.onFetchCompleted(isLatestMessage)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard var message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                DataService.shared.downloadImage(at: url) { [weak self] image in
                    guard let self = self else {
                        return
                    }
                    guard let image = image else {
                        return
                    }
                    
                    message.image = image
                    self.updateChatData(id: message.chatId ?? "", lastMessage: "photo")
                    self.insertNewMessage(message)
                }
            } else {
                insertNewMessage(message)
            }
        default:
            break
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let chatId = chatId else {
            completion(nil)
            return
        }
        
        guard let scaledImage = image.scaledToSafeUploadSize,
            let data = scaledImage.jpegData(compressionQuality: 0.4) else {
                completion(nil)
                return
        }
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        DataService.shared.uploadImage(path: chatId, imageName: imageName, data: data, completion: completion)
    }
    
    // MARK: - Public Helpers
    public func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section - 1].sender.displayName
    }
    
    public func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].sender.displayName == messages[indexPath.section + 1].sender.displayName
    }
    
    public func sendPhoto(_ image: UIImage) {
      uploadImage(image) { [unowned self] url in
        
        guard let url = url else {
          return
        }
        
        self.delegate?.onUploadImageCompleted(with: url, image: image)
      }
    }
    
    // MARK: - API Call
    public func fetchMessages() {
        // Check for avoiding multiple network calls
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        DataService.shared.getMessages { [weak self] (querySnapshot, error) in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                self.delegate?.onFetchFailed(with: error.localizedDescription, errorType: nil)
            } else {
                guard let snapshot = querySnapshot else {
                    self.delegate?.onFetchFailed(with: error?.localizedDescription ?? "No error", errorType: nil)
                    return
                }
                
                if snapshot.count == 0 {
                    self.delegate?.onFetchFailed(with: "No messages yet...", errorType: .chatIsNotCreated)
                }
                
                // Append datas to messages array
                snapshot.documentChanges.forEach { (change) in
                    self.handleDocumentChange(change)
                }
                
                print(self.messages)
            }
            self.isFetchInProgress = false
        }
    }
    
    public func saveMessages(_ message: Message) {
        DataService.shared.saveMessages(data: message.representation) { (error) in
            if let error = error {
                self.delegate?.onSaveFailed(with: error.localizedDescription)
            } else {
                self.updateChatData(id: message.chatId ?? "", lastMessage: message.content)
                self.delegate?.onSaveCompleted()
            }
        }
    }
    
    public func updateChatData(id: String, lastMessage: String) {
        DataService.shared.updateChat(lastMessage: lastMessage, id: id ) { (error) in
            if let error = error {
                print(error)
            } else {
                print("Keyhan: chat updated")
            }
        }
    }
    
    public func removeListener() {
        DataService.shared.removeListener()
    }
}

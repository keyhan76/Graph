//
//  ChatsViewModel.swift
//  ChatApp
//
//  Created by Keyhan on 12/26/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Foundation
import Firebase

class ChatsViewModel {
    
    // MARK: - Private Variables
    private weak var delegate: ChatsViewModelDelegate?
    private var isFetchInProgress = false
    private var chats: [Chats] = []
    
    // MARK: - Public Varibles
    
    public var currentUser = Auth.auth().currentUser
    
    public var totalCount: Int {
        return chats.count
    }
    
    // MARK: - Initializer
    init(delegate: ChatsViewModelDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Helprs
    func chat(at index: Int) -> Chats {
        return chats[index]
    }
    
    func chatType(at index: Int) -> ChatType {
        let chats = chat(at: index)
        
        if chats.members.count > 2 {
            return .group
        } else {
            return .one2one
        }
    }
    
    func chatTitle(at index: Int) -> String {
        let chats = chat(at: index)
        
        if chats.members.count > 2 {
            let title = chats.title
            return title
        } else if chats.members.count == 2 {
            if chats.creatorId == DataService.shared.id {
                guard chats.title.count != 0 else { return ""}
                let titleComponents = chats.title.components(separatedBy: "|")
                let title = titleComponents.first ?? ""
                return title
            } else {
                guard chats.title.count != 0 else { return ""}
                let titleComponents = chats.title.components(separatedBy: "|")
                let title = titleComponents.last ?? ""
                return title
            }
        } else {
            return "Title is not set"
        }
    }
    
    func getUserProfileImage(at index: Int, completion: @escaping (_ url: URL?) -> ())  {
        let chats = chat(at: index)

        if chats.members.count == 2 {
            chats.members.forEach { (id) in
                if id != chats.creatorId {
                    DataService.shared.getUserProfileimg(id: id) { (snapShot, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            guard let doc = snapShot else { return }
                            
                            let user = Users(document: doc)
                            
                            if let url = user?.downloadURL {
                                completion(url)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func addChatToTable(_ chat: inout Chats) {
        guard !chats.contains(chat) else {
            return
        }
        
        guard chat.members.contains(DataService.shared.id ?? "")  else {
            self.delegate?.onFetchFailed(with: "No chats yet...")
            return
        }
        
        chats.append(chat)
        chats.sort()
        
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        // Notify the delegate
        self.delegate?.onFetchCompleted(with: index)
    }
    
    private func updateChatInTable(_ chat: Chats) {
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        
        chats[index] = chat
        self.delegate?.onUpdateCompleted(with: index)
    }
    
    private func removeChatFromTable(_ chat: Chats) {
        guard let index = chats.firstIndex(of: chat) else {
            return
        }
        
        chats.remove(at: index)
        self.delegate?.onRemoveCompleted(with: index)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard var chat = Chats(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChatToTable(&chat)
            
        case .modified:
            updateChatInTable(chat)
            
        case .removed:
            removeChatFromTable(chat)
        }
    }
    
    // MARK: - API Call
    public func fetchChats() {
        // Check for avoiding multiple network calls
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        DataService.shared.fetchChat { [weak self] (querySnapshot, error) in
            
            guard let self = self else {
                return
            }
            
            if let error = error {
                self.delegate?.onFetchFailed(with: error.localizedDescription)
            } else {
                guard let snapshot = querySnapshot else {
                    self.delegate?.onFetchFailed(with: error?.localizedDescription ?? "No error")
                    return
                }
                
                if snapshot.count == 0 {
                    self.delegate?.onFetchFailed(with: "No chat yet...")
                }
                
                // Append datas to chats array
                snapshot.documentChanges.forEach { (change) in
                    self.handleDocumentChange(change)
                }
                
                print(self.chats)
            }
            self.isFetchInProgress = false
        }
    }
    
    public func deleteChat(with chat: Chats) {
        
        guard let id = chat.id else {
            return
        }
        
        DataService.shared.deleteChat(id: id) { [unowned self] (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.removeChatFromTable(chat)
            }
        }
    }
    
    public func removeListener() {
        DataService.shared.removeListener()
    }
}

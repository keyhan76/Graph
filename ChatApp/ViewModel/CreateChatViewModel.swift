//
//  CreateChatViewModel.swift
//  ChatApp
//
//  Created by Keyhan on 1/3/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import Foundation
import Firebase

class CreateChatViewModel {
    
    // MARK: - Private Variables
    private weak var delegate: CreateChatViewModelDelegate?
    private var isFetchInProgress = false
    private var name = ""
    private var users = [Users]()
    
    // MARK: - Public Varibles
    public var currentUser = Auth.auth().currentUser
    
    public var chatTitle: String {
        return name
    }
    
    public var totalUserCount: Int {
        return users.count
    }
    
    // MARK: - Public Helpers
    func user(at index: Int) -> Users {
        return users[index]
    }
    
    // MARK: - Initializer
    init(delegate: CreateChatViewModelDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - API Call
    public func createChat(_ chat: Chats) {
        // Check for avoiding multiple network calls
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        DataService.shared.createChat(data: chat.representation, completion: { [unowned self] (error) in
            if let error = error {
                self.delegate?.onChatFailed(with: error.localizedDescription)
            }
        }) { [unowned self] (document, error) in
            if let error = error {
                self.delegate?.onChatFailed(with: error.localizedDescription)
            } else {
                guard let doc = document else {
                    self.delegate?.onChatFailed(with: error?.localizedDescription ?? "No error")
                    return
                }
                
                guard let chat = Chats(document: doc) else {
                    return
                }
                
                self.delegate?.onChatCreated(with: chat)
            }
            self.isFetchInProgress = false
        }
    }
    
    public func fetchUser(with name: String) {
        DataService.shared.fetchUser(name: name) { [unowned self] (found, selectedUser) in
            if found {
                self.name = name
                guard let user = self.currentUser else { return }
                
                let title = "\(name)|\(DataService.shared.name ?? "")"
                
                let chat = Chats(user: user, title: title, lastMessage: nil, members: [DataService.shared.id ?? "", selectedUser?.id ?? ""])
                
                self.createChat(chat)
            } else {
                self.delegate?.onChatFailed(with: "user not found")
                print("user not found")
            }
        }
    }
    
    public func fetchAllUsers() {
        DataService.shared.fetchAllUsers { [unowned self] (querySnapshot, error) in
            if let error = error {
                self.delegate?.onChatFailed(with: error.localizedDescription)
            } else {
                guard let snapshot = querySnapshot else { return }
                
                // Append datas to users array
                snapshot.documentChanges.forEach { (change) in
                    guard let user = Users(document: change.document) else { return }
                    self.addUsers(user)
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    private func addUsers(_ user: Users) {
        guard !users.contains(user) else {
            return
        }
        
        guard user.id != currentUser?.uid else {
            return
        }
        
        users.append(user)
        users.sort()
        
        // Notify the delegate
        self.delegate?.onUserFetchCompleted()
    }
}


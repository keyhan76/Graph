//
//  ViewModelProtocols.swift
//  ChatApp
//
//  Created by Keyhan on 12/13/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit

// MARK: - Messages View Model Delegate
protocol MessagesViewModelDelegate: class {
    func onFetchCompleted(_ isLatestMessage: Bool)
    func onFetchFailed(with reason: String, errorType: ErrorTypes?)
    func onSaveCompleted()
    func onSaveFailed(with reason: String)
    func onUploadImageCompleted(with url: URL, image: UIImage)
}

// MARK: - Chats View Model Delegate
protocol ChatsViewModelDelegate: class {
    func onFetchCompleted(with index: Int)
    func onUpdateCompleted(with index: Int)
    func onRemoveCompleted(with index: Int)
    func onFetchFailed(with reason: String)
}

// MARK: - Creat Chat View Model Delegate
protocol CreateChatViewModelDelegate: class {
    func onChatCreated(with chat: Chats)
    func onChatFailed(with reason: String)
    func onUserFetchCompleted()
    func onUserFetchFailed(with reason: String)
}

// MARK: - User View Model Delegate
protocol UserViewModelDelegate: class {
    func onFetchCompleted()
    func onFetchFailed(with reason: String)
    func downloadImageCompleted()
    func donwloadImageFailed(with reason: String)
    func onUploadImageCompleted(image: UIImage)
    func onUsernameUpdated(with username: String)
}

//
//  Messages.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
    
    let id: String?
    let content: String
    let sentDate: Date
    var sender: SenderType {
        return senderUser
    }
    var senderUser: SenderUser
    let chatId: String?
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageMediaItem(image: image)
            return .photo(mediaItem)
        } else if content.containsOnlyEmoji {
            return .emoji(content)
        } else {
            return .text(content)
        }
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: User, content: String, chatId: String) {
        senderUser = SenderUser(senderId: user.uid, displayName: DataService.shared.name ?? "unknown")
        self.content = content
        sentDate = Date()
        id = nil
        self.chatId = chatId
    }
    
    init(user: User, image: UIImage, chatId: String) {
        senderUser = SenderUser(senderId: user.uid, displayName: DataService.shared.name ?? "unknown")
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
        self.chatId = chatId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let chatId = data["chatId"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.chatId = chatId
        
        self.sentDate = sentDate.dateValue()
        senderUser = SenderUser(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        if let chatId = chatId {
            rep["chatId"] = chatId
        }
        
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}

private struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 250, height: 340)
        self.placeholderImage = UIImage()
    }
    
}

struct SenderUser: SenderType {
    var senderId: String
    
    var displayName: String
}

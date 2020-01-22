//
//  Chats.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Chats {
    let id: String?
    var title: String
    let lastMessage: String?
    let creatorId: String
    let members: [String]
    let sentDate: Date
    let downloadUrl: URL?
    
    init(user: User, title: String, lastMessage: String?, members: [String]) {
        self.id = nil
        self.title = title
        self.lastMessage = lastMessage
        self.creatorId = user.uid
        self.members = members
        self.sentDate = Date()
        self.downloadUrl = nil
    }
    
    init?(document: QueryDocumentSnapshot, downloadUrl: URL?) {
        let data = document.data()
        
        self.init(data: data, docQuery: document, downloadUrl: downloadUrl)
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.init(data: data, docSnap: document)
    }
    
    private init?(data: [String: Any], docSnap: DocumentSnapshot? = nil, docQuery: QueryDocumentSnapshot? = nil, downloadUrl: URL? = nil) {
        guard let title = data["title"] as? String else {
            return nil
        }
        
        guard let lastMessage = data["lastMessage"] as? String else {
            return nil
        }
        
        guard let creatorId = data["creatorId"] as? String else {
            return nil
        }
        
        guard let members = data["members"] as? [String] else {
            return nil
        }
        
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        
        if let docSnap = docSnap {
            id = docSnap.documentID
        } else if let docQuery = docQuery {
            id = docQuery.documentID
        } else {
            return nil
        }
        
        self.sentDate = sentDate.dateValue()
        self.title = title
        self.lastMessage = lastMessage
        self.creatorId = creatorId
        self.members = members
        self.downloadUrl = downloadUrl
    }
}

extension Chats: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep = [
            "title": title,
            "created": sentDate,
            "lastMessage": lastMessage ?? "No Messages yet...",
            "creatorId": creatorId,
            "members": members
            ] as [String : Any]
        
        if let id = id {
            rep["id"] = id
        }
        
        return rep
    }
}

extension Chats: Comparable {
    
    static func == (lhs: Chats, rhs: Chats) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Chats, rhs: Chats) -> Bool {
        return lhs.title < rhs.title
    }
    
    static func > (lhs: Chats, rhs: Chats) -> Bool {
        return rhs.sentDate > lhs.sentDate
    }
}

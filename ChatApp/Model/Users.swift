//
//  Users.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Users {
    let id: String?
    let name: String
    let username: String?
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(name: String, id: String, username: String?) {
        self.id = id
        self.name = name
        self.username = username
    }
    
    init(name: String, id: String, username: String, image: UIImage) {
        self.id = id
        self.name = name
        self.username = username
        self.image = image
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        self.init(data: data, docQuery: document)
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.init(data: data, docSnap: document)
    }
    
    private init?(data: [String: Any], docSnap: DocumentSnapshot? = nil, docQuery: QueryDocumentSnapshot? = nil) {
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        guard let username = data["username"] as? String else {
            return nil
        }
        
        if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
        } else {
            downloadURL = nil
        }
        
        if let docSnap = docSnap {
            id = docSnap.documentID
        } else if let docQuery = docQuery {
            id = docQuery.documentID
        } else {
            return nil
        }
        
        self.name = name
        self.username = username
    }
    

}

extension Users: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep = [ "name": name ]
        
        if let id = id {
            rep["id"] = id
        }
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        }
        
        if let username = username {
            rep["username"] = username
        }
        
        return rep
    }
}

extension Users: Comparable {
    
    static func == (lhs: Users, rhs: Users) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Users, rhs: Users) -> Bool {
        return lhs.name < rhs.name
    }
    
}

//
//  DataService.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore

class DataService {
    
    // MARK: - Shared Instance
    static let shared = DataService()
    
    // MARK: - Private Variables
    private let db = Firestore.firestore()
    
    private let currentUser = Auth.auth().currentUser
    
    private var chatReference: CollectionReference {
        return db.collection("Chats")
    }
    
    private var userReference: CollectionReference {
      return db.collection("Users")
    }
    
    private var messageReference: CollectionReference {
      return db.collection("Messages")
    }
    
    private let storage = Storage.storage().reference()
    
    private var chats = [Chats]()
    private var listener: ListenerRegistration?
    
    // MARK: - User Defaults
    public var name: String? {
        get {
            return UserDefaults.standard.value(forKey: "name") as? String
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "name")
        }
    }
    
    public var id: String? {
        get {
            return UserDefaults.standard.value(forKey: "id") as? String
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "id")
        }
    }
    
    public var isAuthenticated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isAuthenticated") == true
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "isAuthenticated")
        }
    }
    
    public var walkthroughIsShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "walkthroughIsShown") == true
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "walkthroughIsShown")
        }
    }
    
    // MARK: - DataBase Insertions
    public func createChat(data: [String: Any], completion: ((Error?) -> Void)?, docCompletion: @escaping (_ snapshot: DocumentSnapshot?, _ error: Error?) -> ()) {
        chatReference.addDocument(data: data, completion: completion).getDocument { (doc, error) in
            docCompletion(doc, error)
        }
    }
    
    public func fetchChat(completion: @escaping (_ snapshot: QuerySnapshot?, _ error: Error?) -> ()) {
        listener = chatReference.addSnapshotListener({ (querySnapshot, error) in
            completion(querySnapshot, error)
        })
    }
    
    public func deleteChat(id: String, completion: ((Error?) -> Void)?) {
        chatReference.document("\(id)").delete(completion: completion)
    }
    
    public func updateChat(lastMessage: String, id: String, completion: ((Error?) -> Void)?) {
        chatReference.document("\(id)").updateData(["lastMessage": lastMessage, "created": Date()], completion: completion)
    }
    
    // Save user to the databse
    public func createUser(user: Users) {
        print(user.representation)
        userReference.document("\(user.id ?? "")").setData(user.representation, merge: true) { (error) in
            if let e = error {
              print("Error saving user: \(e.localizedDescription)")
            }
        }
    }
    
    public func saveMessages(data: [String: Any], completion: ((Error?) -> Void)?) {
        messageReference.addDocument(data: data, completion: completion)
    }
    
    // fetch user data based on typed username
    public func fetchUser(name: String, completed: @escaping (_ foundUser: Bool, _ user: Users?) -> ()) {
        userReference.getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            } else {
                guard let snap = snapshot else { return }
                
                var foundUser: Users!
                
                let userFound = snap.documents.contains(where: { (doc) -> Bool in
                    guard let user = Users(document: doc) else { return false }
                    foundUser = user
                    
                    // User cannot start a convo with its self
                    guard user.id != self.currentUser?.uid else { return false }
                    
                    // get username or name of the user
                    let fetchedName = user.name.caseInsensitiveCompare(name)
                    guard let fetchedUsername = user.username?.caseInsensitiveCompare(name) else {
                        return false
                    }
                    
                    if fetchedName == .orderedSame || fetchedUsername == .orderedSame {
                        return true
                    } else {
                        return false
                    }
                })
                
                if userFound {
                    completed(true, foundUser)
                } else {
                    completed(false, nil)
                }
            }
        }
    }
    
    public func getMessages(completion: @escaping (_ snapshot: QuerySnapshot?, _ error: Error?) -> ()) {
        listener = messageReference.addSnapshotListener({ (querySnapshot, error) in
            completion(querySnapshot, error)
        })
    }
    
    public func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
      let ref = Storage.storage().reference(forURL: url.absoluteString)
      let megaByte = Int64(1 * 1024 * 1024)
      
      ref.getData(maxSize: megaByte) { data, error in
        guard let imageData = data else {
          completion(nil)
          return
        }
        
        completion(UIImage(data: imageData))
      }
    }
    
    public func uploadImage(path: String, imageName: String, data: Data, completion: @escaping (URL?) -> Void) {
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let ref = storage.child(path).child(imageName)
        
        ref.putData(data, metadata: metadata) { (meta, error) in
            if let error = error {
                print("There was an Error Uploading image: \(error)")
            } else {
                ref.downloadURL { (url, error) in
                    if let error = error {
                        print(error)
                    } else {
                        completion(url)
                    }
                }
            }
        }
    }
    
    public func getUserProfile(id: String, completion: @escaping (_ snapshot: DocumentSnapshot?, _ error: Error?) -> ()) {
        userReference.document(id).getDocument { (snapShot, error) in
            completion(snapShot, error)
        }
    }
    
    public func fetchAllUsers(completion: @escaping (_ snapshot: QuerySnapshot?, _ error: Error?) -> ()) {
        userReference.getDocuments { (querySnapshot, error) in
            completion(querySnapshot, error)
        }
    }
    
    public func updateUsername(new username: String, id: String, completion: ((Error?) -> Void)?) {
        userReference.document("\(id)").updateData(["username": username], completion: completion)
    }
    
    public func updateUserProfileImage(new url: String, id: String, completion: ((Error?) -> Void)?) {
        userReference.document("\(id)").updateData(["url": url], completion: completion)
    }
    
    
    
    
    // MARK: - Auth Methods
    public func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance()?.signOut()
            isAuthenticated = false
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    // MAARK: - Remove Listeners
    public func removeListener() {
         listener?.remove()
    }
}

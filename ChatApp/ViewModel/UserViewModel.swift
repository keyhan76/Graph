//
//  UserViewModel.swift
//  ChatApp
//
//  Created by Keyhan on 1/10/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit
import Firebase

class UserViewModel {
    // MARK: - Private Variables
    private weak var delegate: UserViewModelDelegate?
    private var isFetchInProgress = false
    private var user: Users!
    private var placeHolderText: String?
     
    // MARK: - Public Variables
    
    public var currentUser = Auth.auth().currentUser
    
    public var name: String? {
        let userName = user.name.components(separatedBy: " ").first
        return userName
    }
    
    public var lastName: String? {
        if user.name.contains(" ") {
            let userLastName = user.name.components(separatedBy: " ").last
            return userLastName
        } else {
            return nil
        }
    }
    
    public var username: String {
        let username = user.username ?? "No Username"
        return "@\(username)"
    }
    
    public var profileImage: UIImage? {
        return user.image
    }
    
    public var profileImagePlaceHolder: String? {
        return placeHolderText
    }
    
    // MARK: - Initializer
    init(delegate: UserViewModelDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - API Calls
    public func fetchUserProfile() {
        
        // Check for avoiding multiple network calls
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        guard let id = currentUser?.uid else {
            return
        }
        
        DataService.shared.getUserProfile(id: id) { [unowned self] (snapshot, error) in
            if let error = error {
                self.delegate?.onFetchFailed(with: error.localizedDescription)
            } else {
                guard let snap = snapshot else {
                    self.delegate?.onFetchFailed(with: "Data Not Available")
                    return
                }
                
                self.user = Users(document: snap)
                self.isFetchInProgress = false
                self.downloadProfileImage(of: self.user)
                self.delegate?.onFetchCompleted()
            }
            self.isFetchInProgress = false
        }
    }
    
    public func sendPhoto(_ image: UIImage) {
      uploadImage(image) { [unowned self] url in
        
        guard let id = self.currentUser?.uid else { return }
        guard let url = url else { return }
        let urlString = url.absoluteString
        
        DataService.shared.updateUserProfileImage(new: urlString, id: id) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.delegate?.onUploadImageCompleted(image: image)
            }
        }
      }
    }
    
    public func updateUsername(with username: String) {
        
        guard let id = currentUser?.uid else {
            return
        }
        
        var cleanUsername = username
        
        if username.contains("@") {
            cleanUsername = String(username.dropFirst())
        }
        
        DataService.shared.updateUsername(new: cleanUsername, id: id) { (error) in
            if let error = error {
                self.delegate?.onFetchFailed(with: "Couldn't update username \(error)")
            } else {
                self.delegate?.onUsernameUpdated(with: username)
            }
        }
    }
    
    // MARK: - Helpers
    private func downloadProfileImage(of user: Users) {
        
        // Check for avoiding multiple network calls
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        if let url = user.downloadURL {
            DataService.shared.downloadImage(at: url) { [weak self] image in
                guard let self = self else {
                    return
                }
                guard let image = image else {
                    self.delegate?.donwloadImageFailed(with: "Image not found")
                    return
                }
                
                self.user.image = image
                self.delegate?.downloadImageCompleted()
                self.placeHolderText = nil
                
                self.isFetchInProgress = false
            }
        } else {
            placeHolderText = String(user.name.prefix(1))
            self.delegate?.donwloadImageFailed(with: "Image not found")
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let id = user.id else {
            completion(nil)
            return
        }
        
        guard let scaledImage = image.scaledToSafeUploadSize,
            let data = scaledImage.jpegData(compressionQuality: 0.4) else {
                completion(nil)
                return
        }
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        DataService.shared.uploadImage(path: id, imageName: imageName, data: data, completion: completion)
    }
}

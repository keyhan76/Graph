//
//  ProfileChildVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/10/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit
import Photos

class ProfileChildVC: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var usernameTxtField: UITextField!
    
    // MARK: - Private Variables
    private var viewModel: UserViewModel!
    private var username: String!
    
    private var isSendingPhoto = false {
      didSet {
        DispatchQueue.main.async {
            if self.isSendingPhoto {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
      }
    }
    
    // MARK: - Public Variables
    public var editedProfile: ((_ username: String, _ newUsername: String, _ viewModel: UserViewModel) -> ())?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeHolderLbl.layer.cornerRadius = placeHolderLbl.frame.width / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2

        Loading.shared.showProgressView(view)
        viewModel = UserViewModel(delegate: self)
        viewModel.fetchUserProfile()
        activityIndicator.startAnimating()
        
        usernameTxtField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let username = usernameTxtField.text, !username.isEmpty else {
            parent?.navigationItem.rightBarButtonItem?.isEnabled = false
            return
        }
        editedProfile?(self.username, username, viewModel)
    }

    // TODO: - Complete profile photo upload process
    @IBAction func profilePhotoBtnTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        parent?.createActionSheet(title: "Set Profile Picture", message: "Choose From:", LibAction: { [unowned self] (_) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }, cameraAction: { [unowned self] (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
        })
    }
}

// MARK: - User View Model Delegate
extension ProfileChildVC: UserViewModelDelegate {
    func onFetchCompleted() {
        nameLbl.text = viewModel.name
        lastNameLbl.text = viewModel.lastName
        usernameTxtField.text = viewModel.username
        self.username = viewModel.username
        Loading.shared.hideProgressView()
    }
    
    func onUsernameUpdated(with username: String) {
        usernameTxtField.text = username
        self.username = usernameTxtField.text
        Loading.shared.hideProgressView()
    }
    
    func onFetchFailed(with reason: String) {
        Loading.shared.hideProgressView()
        print(reason)
    }
    
    func downloadImageCompleted() {
        profileImageView.image = viewModel.profileImage
        activityIndicator.stopAnimating()
    }
    
    func donwloadImageFailed(with reason: String) {
        activityIndicator.stopAnimating()
        placeHolderLbl.text = viewModel.profileImagePlaceHolder
        placeHolderLbl.isHidden = false
        print("Image Download Failed")
    }
    
    func onUploadImageCompleted(image: UIImage) {
        activityIndicator.stopAnimating()
        profileImageView.image = image
        placeHolderLbl.isHidden = true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileChildVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // 1
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: nil) { [unowned self] result, info in
                    
                    guard let image = result else {
                        return
                    }
                    
                    self.isSendingPhoto = true
                    self.viewModel.sendPhoto(image)
            }
            
            // 2
        } else if let image = info[.originalImage] as? UIImage {
            self.isSendingPhoto = true
            self.viewModel.sendPhoto(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

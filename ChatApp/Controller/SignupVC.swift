//
//  SignupVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/13/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth

class SignupVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var signInBtn: GIDSignInButton!
    @IBOutlet weak var usernameTxtField: BottomBorderTxtField!
    
    // MARK: - Private Variables
    private var username: String?
    
    let auth = Auth.auth()

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInUser()
        
        signInBtn.colorScheme = .dark
        signInBtn.style = .wide
        signInBtn.isEnabled = false
        usernameTxtField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    // MARK: - Helpers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func showHomeVC() {
        let vc: CustomTabBarController = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }
    
    private func signInUser() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @objc private func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let username = usernameTxtField.text, !username.isEmpty else {
            self.signInBtn.isEnabled = false
            return
        }
        
        self.username = username
            
        signInBtn.isEnabled = true
    }
}

extension SignupVC: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Error \(error)")
        } else {
            guard let authentication = user.authentication else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { [unowned self] (user, error) in
                if let error = error {
                    print("Error \(error)")
                    return
                }
                let name = user?.additionalUserInfo?.profile?["name"] as? String
                // Save user's name based on its Google profile
                DataService.shared.name = name
                DataService.shared.id = user?.user.uid
                let user = Users(name: DataService.shared.name ?? "No name", id: user?.user.uid ?? "", username: self.username)
                print(user.representation)
                DataService.shared.createUser(user: user)
                
                DataService.shared.isAuthenticated = true
                self.showHomeVC()
            }
        }
    }
}

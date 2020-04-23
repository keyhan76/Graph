//
//  LoginVC.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var signInBtn: GIDSignInButton!
    
    // MARK: - Private Variables
    private let auth = Auth.auth()

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInUser()
        
        signInBtn.colorScheme = .dark
        signInBtn.style = .wide
    }
    
    // MARK: - Actions
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func showHomeVC() {
        let vc: CustomTabBarController = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }
    
    private func signInUser() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
    }
}

extension LoginVC: GIDSignInDelegate {
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
                let user = Users(name: DataService.shared.name ?? "No name", id: user?.user.uid ?? "", username: nil)
                print(user.representation)
                DataService.shared.createUser(user: user)
                
                DataService.shared.isAuthenticated = true
                self.dismiss(animated: true) {
                    self.showHomeVC()
                }
            }
        }
    }
}

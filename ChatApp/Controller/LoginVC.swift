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
    private var handle: AuthStateDidChangeListenerHandle?
    
    let auth = Auth.auth()

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInUser()
        
        signInBtn.colorScheme = .dark
        signInBtn.style = .wide
    }
    
    // MARK: - Deinit
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
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
        handle = Auth.auth().addStateDidChangeListener() { [unowned self] (auth, user) in
            if user != nil {
                DataService.shared.isAuthenticated = true
                self.dismiss(animated: true) {
                    self.showHomeVC()
                }
            }
        }
    }
}

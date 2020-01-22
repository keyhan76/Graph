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
    private var handle: AuthStateDidChangeListenerHandle?
    
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
    
    // MARK: - Deinit
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
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
        handle = Auth.auth().addStateDidChangeListener() { [unowned self] (auth, user) in
            if user != nil {
                DataService.shared.isAuthenticated = true
                self.showHomeVC()
            }
        }
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.username = username
            
        signInBtn.isEnabled = true
    }
}

//
//  WalkthroughThirdVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/13/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class WalkthroughThirdVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var signUpBtn: UIButton!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signUpBtn.layer.cornerRadius = signUpBtn.frame.height / 2
        signUpBtn.layer.masksToBounds = true
    }

    // MARK: - Actions
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        DataService.shared.walkthroughIsShown = true
        showSignUpVC()
    }
    
    @IBAction func loginBtnTapped(_ sender: UIButton) {
        DataService.shared.walkthroughIsShown = true
        showLoginVC()
    }
    
    // MARK: - Helpers
    private func showSignUpVC() {
        let vc: SignupVC = UIStoryboard(storyboard: .main).instantiateViewController()
        
        VCDismisser.shared.animateTovc(animateOption: .transitionFlipFromLeft, viewControllerToAnimate: vc, vctoDissmiss: self)
    }
    
    private func showLoginVC() {
        let vc: LoginVC = UIStoryboard(storyboard: .main).instantiateViewController()
        
        VCDismisser.shared.animateTovc(animateOption: .transitionFlipFromRight, viewControllerToAnimate: vc, vctoDissmiss: self)
    }
}

//
//  SplashVC.swift
//  ChatApp
//
//  Created by Keyhan on 12/12/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard DataService.shared.walkthroughIsShown else {
            showWalkthrough()
            return
        }

        if DataService.shared.isAuthenticated {
            showHomeVC()
        } else {
            showSignUpVC()
        }
    }
    

    // MARK: - Helpers
    private func showHomeVC() {
        let vc: CustomTabBarController = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }
    
    private func showSignUpVC() {
        let vc: SignupVC = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }
    
    private func showWalkthrough() {
        let vc: WalkthroughRootVC = UIStoryboard(storyboard: .main).instantiateViewController()

        VCDismisser.shared.animateTovc(viewControllerToAnimate: vc, vctoDissmiss: self)
    }

}

//
//  WalkthroughRootVC.swift
//  ChatApp
//
//  Created by Keyhan on 1/13/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class WalkthroughRootVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Private Variables
       private lazy var pageViewController: WalkthroughVC = {
           // Load Storyboard
           let viewController: WalkthroughVC = UIStoryboard(storyboard: .main).instantiateViewController()
           
           return viewController
       }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.add(asChildViewController: pageViewController, to: containerView)
    }

    // MARK: - Actions
    @IBAction func skipBtnTapped(_ sender: UIButton) {
        
        DataService.shared.walkthroughIsShown = true
        
        showSignUpVC()
    }
    
    // MARK: - Helpers
    private func showSignUpVC() {
        let vc: SignupVC = UIStoryboard(storyboard: .main).instantiateViewController()
        
        VCDismisser.shared.animateTovc(animateOption: .transitionFlipFromLeft, viewControllerToAnimate: vc, vctoDissmiss: self)
    }

}

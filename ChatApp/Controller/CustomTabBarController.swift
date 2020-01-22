//
//  CustomTabBarController.swift
//  ChatApp
//
//  Created by Keyhan on 1/7/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    private var middleButton: UIButton! {
        didSet {
            middleButton.frame.size = CGSize(width: 70, height: 70)
            middleButton.center = CGPoint(x: tabBar.frame.width / 2, y: 0)
            
            middleButton.setImage(#imageLiteral(resourceName: "home"), for: .normal)
            
            middleButton.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
            
            self.tabBar.addSubview(middleButton)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        middleButton = UIButton()
        
        delegate = self
        selectedIndex = 1
    }

    // Menu Button Touch Action
    @objc func menuButtonAction(sender: UIButton) {
        self.selectedIndex = 1   //to select the middle tab. use "1" if you have only 3 tabs.
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    
}

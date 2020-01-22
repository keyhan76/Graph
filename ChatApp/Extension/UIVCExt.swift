//
//  UIVCExt.swift
//  ChatApp
//
//  Created by Keyhan on 1/13/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

extension UIViewController {
    public func createActionSheet(title: String, message: String, LibAction: ((UIAlertAction) -> Void)?, cameraAction: ((UIAlertAction) -> Void)?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: LibAction))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: cameraAction))
        present(actionSheet, animated: true, completion: nil)
    }
    
    public func add(asChildViewController viewController: UIViewController,to parentView:UIView) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        parentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    public func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
}

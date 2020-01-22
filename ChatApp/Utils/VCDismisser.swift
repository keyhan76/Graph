//
//  VCDismisser.swift
//  ChatApp
//
//  Created by Keyhan on 12/7/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit

class VCDismisser {
    
    static let shared: VCDismisser = VCDismisser()
    
    private init() {}
    
    public func animateTovc(duration: Float = 0.5, animateOption: UIView.AnimationOptions = .transitionCrossDissolve, viewControllerToAnimate vc: UIViewController, vctoDissmiss: UIViewController?, completion : @escaping ()->Void = {} ){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = vc
        
        UIView.transition(with: appDelegate.window!, duration: TimeInterval(duration), options: animateOption , animations: { () -> Void in
            
            appDelegate.window!.rootViewController = vc
        }, completion:{ isfinished in
            completion()
            let keyWindow = UIApplication.shared.keyWindow
            keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        })
    }
}

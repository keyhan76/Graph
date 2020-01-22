//
//  FacebookInputBar.swift
//  ChatApp
//
//  Created by Keyhan on 12/13/19.
//  Copyright © 2019 Advanced Technology. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class FacebookInputBar: InputBarAccessoryView {
    
    public var buttonTapped: ((_ tapped: Bool) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        self.backgroundColor = .clear
        isTranslucent = false
        contentView.backgroundColor = .clear
        backgroundView.backgroundColor = .clear
        
        setRightStackViewWidthConstant(to: 36, animated: false)
        sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.image = #imageLiteral(resourceName: "icons8-up_arrow")
        sendButton.title = nil
        sendButton.imageView?.layer.cornerRadius = 16
        middleContentViewPadding.right = -38
        
        sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .primary
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.75, alpha: 1)
                })
        }
        
        
        let button = InputBarButtonItem()
        button.onKeyboardSwipeGesture { item, gesture in
            if gesture.direction == .left {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)
            } else if gesture.direction == .right {
                item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)
            }
        }
        
        button.onTouchUpInside { [unowned self] (butt) in
            self.buttonTapped?(true)
        }
        button.setSize(CGSize(width: 40, height: 40), animated: false)
        button.setImage(#imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        
        inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.placeholder = "Message..."
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.autocorrectionType = .no
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setLeftStackViewWidthConstant(to: 40, animated: false)
        setStackViewItems([button], forStack: .left, animated: false)
    }
    
}


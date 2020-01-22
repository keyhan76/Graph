//
//  ChatCell.swift
//  ChatApp
//
//  Created by Keyhan on 1/7/20.
//  Copyright © 2020 Advanced Technology. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeHolderLbl.layer.cornerRadius = placeHolderLbl.frame.width / 2
        placeHolderLbl.clipsToBounds = true
//        placeHolderLbl.alpha = 0
        profileImgView.alpha = 0
    }

    public func configureCell(chat: Chats, title: String) {
        titleLbl.text = title
        messageLbl.text = chat.lastMessage
        
        // Calculate date
        let date = chat.sentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let strDate = formatter.string(from: date)
        timeLbl.text = strDate
        
        let title = title.prefix(1)
        placeHolderLbl.text = String(title)
    }
}

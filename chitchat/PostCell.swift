//
//  PostCell.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/24/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell
{
    @IBOutlet var clientLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        clientLabel.adjustsFontForContentSizeCategory = true
        messageLabel.adjustsFontForContentSizeCategory = true
    }
}

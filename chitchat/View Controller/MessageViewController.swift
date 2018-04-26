//
//  MessageViewController.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/26/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit
import Kingfisher

class MessageViewController: UIViewController
{
    var currentMessage: Message!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let imageURL = currentMessage.getImageURLInMessage()
        {
            imageView.kf.setImage(with: imageURL)
        }
    }
}

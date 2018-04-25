//
//  PostTableViewCell.swift
//  chitchat
//
//  Created by Adam DeCosta on 4/3/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell
{
    static var networkManager: NetworkManager?

    @IBOutlet weak var client: UILabel!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var numDislikes: UILabel!
    @IBOutlet weak var post: UILabel!
    
    var chatID: String = String()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likePost(_ sender: UIButton)
    {
        PostTableViewCell.networkManager?.likeMessage(chatID: chatID)
    }
    
    @IBAction func dislikePost(_ sender: UIButton)
    {
        PostTableViewCell.networkManager?.dislikeMessage(chatID: chatID)
    }
    
}

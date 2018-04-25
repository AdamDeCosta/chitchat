//
//  Message.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/19/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import Foundation

class Message: NSObject
{
    var _id: String?
    var likes: Int?
    var dislikes: Int?
    @objc var client: String?
    @objc var message: String?
}

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
    var location: [Double?] = [nil, nil]
    @objc var client: String?
    @objc var message: String?
    
    static var supportedImgFormats = [".png", ".jpg", ".gif", ".jpeg", ".JPG", ".GIF", ".PNG"]
    
    func getImageURLInMessage() -> URL?
    {
        var imgURL: URL? = nil
        
        if let msg = message
        {
            //URL detection code studied from
            //https://www.hackingwithswift.com/example-code/strings/how-to-detect-a-url-in-a-string-using-nsdatadetector
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: msg, options: [], range: NSRange(location: 0, length: msg.utf16.count))
            
            
            var isValidImgURL = false
            
            for match in matches
            {
                guard let range = Range(match.range, in: msg) else { continue }
                let url = msg[range]
                print(url)
                
                for i in 0..<Message.supportedImgFormats.count
                {
                    if url.contains(Message.supportedImgFormats[i])
                    {
                        imgURL = URL(string: String(url))
                        isValidImgURL = true
                        break
                    }
                }
                
                if isValidImgURL
                {
                    break
                }
            }
        }
        
        return imgURL
    }
}

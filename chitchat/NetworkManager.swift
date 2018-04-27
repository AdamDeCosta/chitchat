//
//  NetworkManager.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/19/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkManager
{
    @objc var messages = [Message]()
    static var urlStoreName = String("URLStore")
    var username: String
    
    let reactionArchiveURL : URL =
    {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("reactions.archive")
    }()
    
    var reactionCache: [String] = []
    
    var reload: (() -> Void)?
    
    init(username: String)
    {
        if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: reactionArchiveURL.path) as? [String]
        {
            reactionCache.append(contentsOf: archivedItems)
        }
        
        self.username = username


    }
    
    func getMessage(chatID: String) -> Message?
    {
        for message in messages
        {
            if message._id == chatID
            {
                return message
            }
        }
        return nil
    }
    
    func getMessageIndex(chatID: String) -> Int?
    {
        for i in 0..<messages.count
        {
            if messages[i]._id == chatID
            {
                return i
            }
        }
        return nil
    }
    
    func loadMessages(completion: @escaping () -> Void)
    {
        if let url = URL(string: NetworkManager.getURLString(forKey: "url") + NetworkManager.getUserString(forKey: username))
        {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let err = error
                {
                    print(err.localizedDescription)
                }
                else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data
                {
                    print("Connected successfully!")
                    
                    do
                    {
                        let jsonObject = try JSONSerialization.jsonObject(with: data)
                        
                        if let jsonDictionary = jsonObject as? [String:Any], let messages = jsonDictionary["messages"] as? [[String:Any]]
                        {
                            self.messages = []
                            for currentMessage in messages
                            {
                                if let comment = currentMessage["message"], let client = currentMessage["client"] as? String, let _id = currentMessage["_id"] as? String, let likes = currentMessage["likes"] as? Int, let dislikes = currentMessage["dislikes"] as? Int, let date = currentMessage["date"] as? String
                                {
                                    let messageObj: Message = Message()
                                    messageObj._id = _id
                                    messageObj.client = client
                                    messageObj.message = comment as? String
                                    messageObj.likes = likes
                                    messageObj.dislikes = dislikes
                                    messageObj.date = date
                                    if let loc = currentMessage["loc"] as? [String] {
                                        messageObj.location = [Double(loc[1]), Double(loc[0])]
                                        print(messageObj.location)
                                    }
                                    self.messages.append(messageObj)
                                }
                            }
                            
                            completion()
                        }
                    }
                    catch
                    {
                        print("Error reading json data from the server.")
                    }
                }
            }.resume()
        }
        else
        {
            print("Uh oh, that's not a valid URL.")
        }
    }
    
    
    // Source: https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
    // Mixed with what is found in loadMessages()
    
    func likeMessage(chatID: String)
    {
        for reaction in reactionCache
        {
            if chatID == reaction
            {
                return
            }
        }
        
        self.reactionCache.append(chatID)
        
        // Create message URL for this particular chat
        let request = URLRequest(url: URL(string: NetworkManager.getURLString(forKey: "url") + NetworkManager.getURLString(forKey: "like") + "\(chatID)" + NetworkManager.getUserString(forKey: username))!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:
        { data, response, error in
            
            // If there is an error or the data is nil return
            guard error == nil else
            {
                return
            }
            
            guard let data = data else
            {
                return
            }
            
            do
            {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                {
                    print(json)
                    // Stores the chat in our "reactionCache" so it can't be liked or disliked again
                    if json["message"] as? String == "Success"
                    {
                        NSKeyedArchiver.archiveRootObject(chatID, toFile: self.reactionArchiveURL.path)
                        self.getMessage(chatID: chatID)?.likes! += 1
                        self.reload!()
                    }
                    else
                    {
                        if let index = self.getMessageIndex(chatID: chatID)
                        {
                            self.messages.remove(at: index)
                        }
                    }
                }
            }
            catch let error
            {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func dislikeMessage(chatID: String)
    {
        for reaction in reactionCache
        {
            if chatID == reaction
            {
                return
            }
        }
        
        self.reactionCache.append(chatID)
        
        // Create message URL for this particular chat
        let request = URLRequest(url: URL(string: NetworkManager.getURLString(forKey: "url") + NetworkManager.getURLString(forKey: "dislike") + "\(chatID)" + NetworkManager.getUserString(forKey: username))!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:
        { data, response, error in
            
            // If there is an error or the data is nil return
            guard error == nil else
            {
                return
            }
            
            guard let data = data else
            {
                return
            }
            
            do
            {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                {
                    print(json)
                    // Stores the chat in our "reactionCache" so it can't be liked or disliked again
                    if json["message"] as? String == "Success"
                    {
                        self.reactionCache.append(chatID)
                        NSKeyedArchiver.archiveRootObject(self.reactionCache, toFile: self.reactionArchiveURL.path)
                        self.getMessage(chatID: chatID)?.dislikes! += 1
                        self.reload!()
                    }
                    else
                    {
                        if let index = self.getMessageIndex(chatID: chatID)
                        {
                            self.messages.remove(at: index)
                        }
                    }
                }
            }
            catch let error
            {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
    }
    
    func sendChat(chat: String, location: CLLocation?)
    {
        let message: String = (chat.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))!
        
        var requestURL: URL?
        
        if let lon = location?.coordinate.longitude, let lat = location?.coordinate.latitude {
            if let tmp = URL(string: NetworkManager.getURLString(forKey: "url") + NetworkManager.getUserString(forKey: username) + NetworkManager.getURLString(forKey: "message") + "\(message)" + "&lat=\(lat)&lon=\(lon)") {
                requestURL = tmp
            }
        }
        else {
            if let tmp = URL(string: NetworkManager.getURLString(forKey: "url") + NetworkManager.getUserString(forKey: username) + NetworkManager.getURLString(forKey: "message") + "\(message)") {
                requestURL = tmp
            }
        }
        
        
        if let url = requestURL
        {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:
            { data, response, error in
                
                guard error == nil else
                {
                    return
                }
                
                guard let data = data else
                {
                    return
                }
                
                do
                {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    {
                        print(json)
                    }
                }
                catch let error
                {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
        else
        {
            print("failed")
        }
    }
    
    //Returns the url location of where the image is
    public static func getURLString(forKey key: String) -> String
    {
        if let path = Bundle.main.path(forResource: urlStoreName, ofType: "plist")
        {
            if let list = NSDictionary(contentsOfFile: path)
            {
                return list.value(forKey: key) as! String
            }
        }
        
        return "INVALID KEY IN \(urlStoreName).plist FOR KEY: \(key)"
    }
    
    //Returns the url location of where the image is
    public static func getUserString(forKey username: String) -> String
    {
        if let path = Bundle.main.path(forResource: urlStoreName, ofType: "plist")
        {
            if let list = NSDictionary(contentsOfFile: path), let userList = list.value(forKey: "username") as! NSDictionary?, let passwordList = list.value(forKey: "password") as! NSDictionary?
            {
                return (userList.value(forKey: username) as! String) + (passwordList.value(forKey: username) as! String)
            }
        }
        
        return ("INVALID USERNAME AND PASSWORD FOR KEY: \(username)")
    }
}

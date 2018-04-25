//
//  NetworkManager.swift
//  chitchat
//
//  Created by Andrew Rimpici on 4/19/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import Foundation

class NetworkManager
{
    @objc var messages = [Message]()
    
    let reactionArchiveURL : URL = {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("reactions.archive")
    }()
    
    let likeURL : String = "https://www.stepoutnyc.com/chitchat/like/"
    let dislikeURL : String = "https://www.stepoutnyc.com/chitchat/dislike/"
    
    var reactionCache: [String] = []
    
    var reload: (() -> Void)?
    
    init() {
        if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: reactionArchiveURL.path) as? [String] {
            reactionCache.append(contentsOf: archivedItems)
        }
        
    }
    
    func getMessage(chatID: String) -> Message? {
        for message in messages {
            if message._id == chatID {
                return message
            }
        }
        return nil
    }
    
    func getMessageIndex(chatID: String) -> Int? {
        for i in 0..<messages.count {
            if messages[i]._id == chatID {
                return i
            }
        }
        return nil
    }
    
    
    func loadMessages(urlString: String, completion: @escaping () -> Void)
    {
        messages = []
        if let url = URL(string: urlString)
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
                            for currentMessage in messages
                            {
                                if let comment = currentMessage["message"], let client = currentMessage["client"] as? String, let _id = currentMessage["_id"] as? String, let likes = currentMessage["likes"] as? Int, let dislikes = currentMessage["dislikes"] as? Int
                                {
                                    let messageObj: Message = Message()
                                    messageObj._id = _id
                                    messageObj.client = client
                                    messageObj.message = comment as? String
                                    messageObj.likes = likes
                                    messageObj.dislikes = dislikes
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
    func likeMessage(chatID: String) {
        for reaction in reactionCache {
            if chatID == reaction {
                return
            }
        }
        
        self.reactionCache.append(chatID)
        
        // Create message URL for this particular chat
        let request = URLRequest(url: URL(string: "\(likeURL)\(chatID)?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600")!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            // If there is an error or the data is nil return
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(json)
                    // Stores the chat in our "reactionCache" so it can't be liked or disliked again
                    if json["message"] as? String == "Success" {
                        NSKeyedArchiver.archiveRootObject(chatID, toFile: self.reactionArchiveURL.path)
                        self.getMessage(chatID: chatID)?.likes! += 1
                        self.reload!()
                    }
                    else {
                        if let index = self.getMessageIndex(chatID: chatID) {
                            self.messages.remove(at: index)
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func dislikeMessage(chatID: String) {
        for reaction in reactionCache {
            if chatID == reaction {
                return
            }
        }
        
        self.reactionCache.append(chatID)
        
        // Create message URL for this particular chat
        let request = URLRequest(url: URL(string: "\(dislikeURL)\(chatID)?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600")!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            // If there is an error or the data is nil return
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print(json)
                    // Stores the chat in our "reactionCache" so it can't be liked or disliked again
                    if json["message"] as? String == "Success" {
                        self.reactionCache.append(chatID)
                        NSKeyedArchiver.archiveRootObject(self.reactionCache, toFile: self.reactionArchiveURL.path)
                        self.getMessage(chatID: chatID)?.dislikes! += 1
                        self.reload!()
                    }
                    else {
                        if let index = self.getMessageIndex(chatID: chatID) {
                            self.messages.remove(at: index)
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
    }
    
    func sendChat(chat: String) {

        let message = chat.replacingOccurrences(of: " ", with: "%20")
        
        if let url = URL(string: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600&message=\(message)") {
        
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print(json)
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
            
        }
        else {
            print("failed")
        }
    }
}

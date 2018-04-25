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
    
    func loadMessages(urlString: String)
    {
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
                                if let comment = currentMessage["message"], let client = currentMessage["client"] as? String
                                {
                                    print("\(client): \(comment)")
                                    let messageObj: Message = Message()
                                    messageObj.client = client
                                    messageObj.message = comment as? String
                                    self.messages.append(messageObj)
                                }
                            }
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
}

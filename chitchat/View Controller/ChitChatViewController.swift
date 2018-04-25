//
//  ChitChatViewController.swift
//  chitchat
//
//  Created by Adam DeCosta on 4/3/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit

class ChitChatViewController: UITableViewController
{
    var networkManager: NetworkManager!
    @IBOutlet weak var postField: UITextField!
    
    /*
        https://www.youtube.com/watch?v=RvDYlPRm5Ww
        On how to do swipe to refresh
     */
    lazy var tableViewRefreshControl: UIRefreshControl =
    {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.refreshControl = tableViewRefreshControl
        
        self.networkManager?.loadMessages(urlString: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600", completion: { self.reloadTableView() } )
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        networkManager.reload =
        {
            self.reloadTableView()
        }
    }
    
    @objc func fetchData()
    {
        DispatchQueue.main.async
        {
            self.networkManager?.loadMessages(urlString: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600", completion: { self.reloadTableView() } )
        }
    }
    
    @objc func reloadTableView()
    {
        DispatchQueue.main.async
        {
            self.tableView.reloadData()
            self.tableViewRefreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return networkManager.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell

        //If the connection fails the message count will be 0. Test to make sure there is at least one message before accessing the array.
        if networkManager.messages.count > 0
        {
            let post = networkManager.messages[indexPath.row]
            
            cell.chatID = post._id!
            cell.client.text = post.client
            cell.post.text = post.message
            cell.numLikes.text = String(post.likes!)
            cell.numDislikes.text = String(post.dislikes!)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let likeAction = UIContextualAction(style: .normal, title:  "Like", handler:
        { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            var isSuccess = false
            let post = self.networkManager.messages[indexPath.row]
            if let id = post._id
            {
                self.networkManager.likeMessage(chatID: id)
                isSuccess = true
            }
            
            success(isSuccess)
        })
        
        likeAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [likeAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let dislikeAction = UIContextualAction(style: .normal, title:  "Dislike", handler:
        { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            var isSuccess = false
            let post = self.networkManager.messages[indexPath.row]
            if let id = post._id
            {
                self.networkManager.dislikeMessage(chatID: id)
                isSuccess = true
            }
            
            success(isSuccess)
        })
        
        dislikeAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [dislikeAction])
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }
    
    @IBAction func sendChat(_ sender: UIButton)
    {
        if let chat = postField.text
        {
            print("chat")
            networkManager.sendChat(chat: chat)
            networkManager?.loadMessages(urlString: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600", completion: { self.fetchData() } )
            postField.text = ""
        }
    }
}

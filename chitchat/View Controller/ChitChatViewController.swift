//
//  ChitChatViewController.swift
//  chitchat
//
//  Created by Adam DeCosta on 4/3/18.
//  Copyright © 2018 Adam DeCosta. All rights reserved.
//

import UIKit

class ChitChatViewController: UITableViewController {
    
    var networkManager: NetworkManager!
    @IBOutlet weak var postField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager?.loadMessages(urlString: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600", completion: { self.reload() } )
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        networkManager.reload = {
            self.reload()
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return networkManager.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell

        let post = networkManager.messages[indexPath.row]
        cell.chatID = post._id!
        cell.client.text = post.client
        cell.post.text = post.message
        cell.numLikes.text = String(post.likes!)
        cell.numDislikes.text = String(post.dislikes!)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        if let chat = postField.text {
            print("chat")
            networkManager.sendChat(chat: chat)
            networkManager?.loadMessages(urlString: "https://www.stepoutnyc.com/chitchat?client=adam.decosta@mymail.champlain.edu&key=9eb6f58a-8129-4de4-a918-7c17a2447600", completion: { self.reload() } )
            postField.text = ""
        }
    }
}

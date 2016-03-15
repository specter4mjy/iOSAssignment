//
//  TweetsTVC.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class TweetsTVC: UITableViewController, UITextFieldDelegate,UITabBarDelegate {
    
    
    @IBOutlet weak var twitterQueryTextField: UITextField!{
        didSet{
            twitterQueryTextField.delegate = self
        }
    }
    var tweets = [[Tweet]]()
    
    struct UserDefaultKeys{
        static let searchHistories = "SearchHistory"
    }
    
    
    
    var twitterQueryText = "#image" {
        didSet{
            // Strange !!!
            // I should use navi
            
//            navigationController?.popViewControllerAnimated(true)
//            if navigationController?.visibleViewController != self{
//                navigationController?.popViewControllerAnimated(true)
//            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            var searchData = defaults.stringArrayForKey(UserDefaultKeys.searchHistories) ?? [String]()
            searchData.insert(twitterQueryText, atIndex: 0)
            defaults.setObject(searchData, forKey: UserDefaultKeys.searchHistories)
            defaults.synchronize()
            
            twitterQueryTextField?.text = twitterQueryText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
            
            
        }
    }
    
    
    private func refresh(){
       let request = TwitterRequest(search: twitterQueryText, count: 50)
        request.fetchTweets { newTweets in
            dispatch_async(dispatch_get_main_queue() ){
                self.tweets.insert( newTweets, atIndex: 0)
                self.tableView.reloadData()
            }
        }
    
    }
    
    private struct Identifiers {
        static let prototypeCell = "tweetCell"
        static let clickSegue = "Show Mentions"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        twitterQueryText = textField.text!
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        twitterQueryTextField.text = twitterQueryText
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refresh()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.prototypeCell, forIndexPath: indexPath)

        let tweetCell = cell as! TweetTVCell
        tweetCell.tweet = tweets[indexPath.section][indexPath.row]
        return tweetCell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
            case Identifiers.clickSegue:
                if let dvc = segue.destinationViewController as? MensionsTableViewController{
                    let senderCell = sender as! TweetTVCell
                    dvc.tweet = senderCell.tweet
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindSegueAction(unwindSegue: UIStoryboardSegue){ }
    
}

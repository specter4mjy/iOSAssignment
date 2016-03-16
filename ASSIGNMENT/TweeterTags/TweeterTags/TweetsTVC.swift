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
    
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var twitterQueryText = "#UCD" {
        didSet{
            
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
        
        
        if let searchData = defaults.stringArrayForKey(UserDefaultKeys.searchHistories) {
            twitterQueryText = searchData.first!
        }
        else{
            twitterQueryTextField.text = twitterQueryText
        }
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refresh()
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

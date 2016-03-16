//
//  HistoryTableViewController.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/14/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

protocol NeedPopToRootVCDelegate{
    var needPopToRootVC:Bool {get set}
}

class HistoryTableViewController: UITableViewController {
    
    private struct Identifiers{
        static let historyItemCell = "history item cell"
    }
    
    struct UserDefaultKeys{
        static let searchHistories = "SearchHistory"
    }
    
    var searchData : [String]? 
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        searchData = defaults.stringArrayForKey(UserDefaultKeys.searchHistories)
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let historyCount = searchData?.count ?? 0
        return historyCount > 100 ? 100 : historyCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.historyItemCell, forIndexPath: indexPath)
        cell.textLabel?.text = searchData![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var searchVC = tabBarController?.viewControllers![0]
        if let nVC = searchVC as? UINavigationController{
            searchVC = nVC.viewControllers[0]
            if nVC.viewControllers.count > 1{
                var topVC = nVC.visibleViewController as! NeedPopToRootVCDelegate
                topVC.needPopToRootVC = true
            }
        }
        let tweetVC = searchVC as! TweetsTVC
        tweetVC.twitterQueryText = searchData![indexPath.row]
        tabBarController?.selectedIndex = 0
        
    }


}

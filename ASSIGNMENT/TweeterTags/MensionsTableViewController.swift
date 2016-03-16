//
//  MensionsTableViewController.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class MensionsTableViewController: UITableViewController, NeedPopToRootVCDelegate {
    
    private let sectionTitles:[String?] = ["Images","URLs","Hashtags","Users"]
    
    private struct Identifiers {
        static let imageCell  = "ImageCell"
        static let textCell   = "TextCell"
        static let showImage  = "Show Tweet Image"
        static let showSearch = "Show Search"
    }
    
    private var tweetData = [[String]]()
    
    
    var tweet : Tweet?{
        didSet{
            tweetData.removeAll()
            tweetData.append((tweet?.media.map{ $0.url.description})!)
            tweetData.append((tweet?.urls.map{ $0.keyword})!)
            tweetData.append((tweet?.hashtags.map{ $0.keyword})!)
            tweetData.append((tweet?.userMentions.map{ $0.keyword})!)
            refresh()
        }
    }
    
    
    private func refresh(){
        tableView.reloadData()
    }

    var needPopToRootVC = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if needPopToRootVC {
            navigationController?.popToRootViewControllerAnimated(true)
            needPopToRootVC = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetData[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let data = tweetData[indexPath.section][indexPath.row]
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.imageCell, forIndexPath: indexPath)
            let imageCell = cell as! ImageTableViewCell
            fetchImage(imageCell, data: data)
            return imageCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.textCell, forIndexPath: indexPath)
            cell.textLabel?.text = data
            return cell
        }
    }
    
    private func fetchImage(imageCell : ImageTableViewCell, data: String) {
        dispatch_async(dispatch_get_global_queue (QOS_CLASS_USER_INITIATED, 0)){
            let imageUrl = NSURL(string: data)
            if let imageData = NSData(contentsOfURL: imageUrl!){
                dispatch_async( dispatch_get_main_queue()){
                    let image = UIImage(data: imageData)
                    imageCell.tweetImage = image
                }
            }
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles.map{ tweetData[section].isEmpty ? nil : $0 }[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section{
        case 0:
            performSegueWithIdentifier(Identifiers.showImage, sender: tableView.cellForRowAtIndexPath(indexPath))
        case 1:
            let urlString = tweetData[indexPath.section][indexPath.row]
            let url = NSURL(string: urlString)
            UIApplication.sharedApplication().openURL(url!)
        case 2...3:
            performSegueWithIdentifier(Identifiers.showSearch, sender: tableView.cellForRowAtIndexPath(indexPath))
        default:break
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        case 0:
            if let aspectRatio = tweet?.media.first?.aspectRatio{
            return view.bounds.width / CGFloat(aspectRatio)
            }else{
                fallthrough
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier{
            switch identifier{
            case Identifiers.showImage:
                if let tweetImageVC = segue.destinationViewController as? TweetImageViewController{
                    if let imageCell = sender as? ImageTableViewCell{
                        tweetImageVC.tweetImage = imageCell.tweetImage
                    }
                }
            case Identifiers.showSearch:
                if let tweetsTVC = segue.destinationViewController as? TweetsTVC{
                    if let textCell = sender as? UITableViewCell{
                        tweetsTVC.twitterQueryText = (textCell.textLabel?.text)!
                    }
                }
            default:break
            }
        }
    }
    
    
}
































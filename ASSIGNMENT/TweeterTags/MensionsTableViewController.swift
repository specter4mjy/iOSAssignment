//
//  MensionsTableViewController.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class MensionsTableViewController: UITableViewController {
    
    private let sectionTitles = ["Images","URLs","Hashtags","Users"]
    
    private struct Identifiers {
        static let imageCell = "ImageCell"
        static let textCell  = "TextCell"
    }
    
    private var tweetData = [[String]]()
    
    
    var tweet : Tweet?{
        didSet{
            tweetData.removeAll()
            tweetData.append([""])
            tweetData.append((tweet?.urls.map{ $0.keyword})!)
            tweetData.append((tweet?.hashtags.map{ $0.keyword})!)
            tweetData.append((tweet?.userMentions.map{ $0.keyword})!)
            refresh()
        }
    }
    
    private func refresh(){
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? (tweet?.media.count)! : tweetData[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.imageCell, forIndexPath: indexPath)
            let imageCell = cell as! ImageTableViewCell
            dispatch_async(dispatch_get_global_queue (QOS_CLASS_USER_INITIATED, 0)){
                if let imageData = NSData(contentsOfURL: (self.tweet?.media.first?.url)!){
                    dispatch_async( dispatch_get_main_queue()){
                        let image = UIImage(data: imageData)
                        imageCell.tweetImage = image
                    }
                }
            }
            return imageCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.textCell, forIndexPath: indexPath)
            cell.textLabel?.text = tweetData[indexPath.section][indexPath.row]
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles.map{
            if section == 0{
                return ((tweet?.media.isEmpty) != nil) ? nil : $0
            }
            else {
                return tweetData[section].isEmpty ? nil : $0
            }
        }[section]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

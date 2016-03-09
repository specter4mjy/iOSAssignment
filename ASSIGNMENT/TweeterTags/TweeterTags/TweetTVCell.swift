//
//  TweetTVCell.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class TweetTVCell: UITableViewCell {
    var tweet : Tweet? {
        didSet{
            updateUI()
        }
    }

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet{
            avatarImageView.layer.cornerRadius = 5.0
        }
    }

    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private struct MyColors{
        static let Green = UIColor(red: 0.2275, green: 0.5098, blue: 0.251, alpha: 1.0)
        static let Blue  = UIColor(red: 0.3137, green: 0.5137, blue: 0.698, alpha: 1.0)
        static let Red   = UIColor(red: 0.8, green: 0.2941, blue: 0.2941, alpha: 1.0)
    }
    
    private func updateUI(){
        userScreenNameLabel.text = tweet?.user.screenName
        
        let myAttributeString = NSMutableAttributedString(string: (tweet?.text)!)
        for hashtag in (tweet?.hashtags)!{
            myAttributeString.addAttribute(NSForegroundColorAttributeName, value: MyColors.Blue, range: hashtag.nsrange)
        }
        for url in (tweet?.urls)!{
            myAttributeString.addAttribute(NSForegroundColorAttributeName, value: MyColors.Red, range: url.nsrange)
        }
        for userMention in (tweet?.userMentions)!{
            myAttributeString.addAttribute(NSForegroundColorAttributeName, value: MyColors.Green, range: userMention.nsrange)
        }
        tweetContentLabel.attributedText = myAttributeString
        
        let dataFomator = NSDateFormatter()
        dataFomator.dateFormat = "dd MMM"
        dateLabel.text = dataFomator.stringFromDate((tweet?.created)!)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let imageData = NSData(contentsOfURL: (self.tweet?.user.profileImageURL)!)
            dispatch_async(dispatch_get_main_queue()) {
            let userProfileImage = UIImage(data: imageData!)
            self.avatarImageView.image = userProfileImage
            }
        }
    }
}

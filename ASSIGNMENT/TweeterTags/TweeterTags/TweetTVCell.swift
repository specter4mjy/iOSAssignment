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
    
    private func updateUI(){
        userScreenNameLabel.text = tweet?.user.screenName
        tweetContentLabel.text = tweet?.text
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

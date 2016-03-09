//
//  ImageTableViewCell.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    var tweetImage : UIImage?{
        didSet{
            tweetImageView.image = tweetImage
        }
    }
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
}

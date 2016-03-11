//
//  TweetImageViewController.swift
//  TweeterTags
//
//  Created by Junyang ma on 3/10/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class TweetImageViewController: UIViewController,UIScrollViewDelegate {
    
    private struct Constants{
        static let maxOverMinZoomScaleRatio:CGFloat = 3
    }

    @IBOutlet weak var imageScrollView: UIScrollView!{
        didSet{
            imageScrollView.delegate = self
        }
    }
    
    private var tweetImageView = UIImageView()
    
    var tweetImage :UIImage? {
        didSet{
            tweetImageView.image = tweetImage
            tweetImageView.sizeToFit()
            tweetImageView.contentMode = .Center
        }
    }
    
    private func setupUI(){
        let viewHeight = imageScrollView.bounds.size.height
        let viewWidth = imageScrollView.bounds.size.width
        let imageHeight = (tweetImage?.size.height)!
        let imageWidth = (tweetImage?.size.width)!
        let scrollViewWidthOverImageViewWidthRatio = viewWidth / imageWidth
        let scrollHeightOverImageViewHeightRatio =  viewHeight / imageHeight
        let minScaleRatio = min(scrollHeightOverImageViewHeightRatio, scrollViewWidthOverImageViewWidthRatio)
        imageScrollView.minimumZoomScale = minScaleRatio
        imageScrollView.maximumZoomScale = minScaleRatio * Constants.maxOverMinZoomScaleRatio
        imageScrollView.contentSize = (tweetImage?.size)!
        imageScrollView.zoomScale = minScaleRatio
        let topBottonInset =  (viewHeight - imageHeight * minScaleRatio) / 2
        let letRightInset  =  (viewWidth  - imageWidth  * minScaleRatio) / 2
        imageScrollView.contentInset = UIEdgeInsetsMake(topBottonInset, letRightInset, topBottonInset, letRightInset)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.addSubview(tweetImageView)
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        setupUI()
    }

    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return tweetImageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

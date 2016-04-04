//
//  ViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit


class BreakoutViewController: UIViewController {

    @IBOutlet weak var gameView: UIView!
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return dynamicAnimator
    }()
    
    private lazy var ballView : UIView = {
        let size = CGSize(width: 20, height: 20)
        let origin = CGPoint(x: self.gameView.bounds.midX, y: self.gameView.bounds.midY)
        let rect = CGRect(origin: origin, size: size)
        var ballView = UIView(frame: rect)
        ballView.backgroundColor = UIColor.darkGrayColor()
        ballView.layer.cornerRadius = 10
        return ballView
    }()
    
    private lazy var paddleView : UIView = {
        
    }()
    
    
    private var breakoutBehavior = BreakoutBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicAnimator.addBehavior(breakoutBehavior)

    }
    
    override func viewDidLayoutSubviews() {
        breakoutBehavior.addItem(ballView)

        
        let pushBehavior = UIPushBehavior(items: [ballView], mode: .Instantaneous)
        pushBehavior.setAngle(CGFloat(-M_PI_4), magnitude: 0.15)
        pushBehavior.action = { [unowned pushBehavior] in
            self.dynamicAnimator.removeBehavior(pushBehavior)
        }
        dynamicAnimator.addBehavior(pushBehavior)

    }
    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        if sender.state == .Ended{
            
        }
    }
}


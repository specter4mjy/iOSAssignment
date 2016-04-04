//
//  ViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit


class BreakoutViewController: UIViewController {
    
    let breakoutModel = BreakoutModel()
    
    let paddleIdentifier = "paddle"

    @IBOutlet weak var gameView: UIView!
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return dynamicAnimator
    }()
    
    

    
    private lazy var ballView : UIView = {
        let size = self.breakoutModel.ballSize
        let origin = CGPoint(x: self.gameView.bounds.midX - size.width / 2, y: self.gameView.bounds.midY - size.height / 2)
        let rect = CGRect(origin: origin, size: size)
        var ballView = UIView(frame: rect)
        ballView.backgroundColor = UIColor.darkGrayColor()
        ballView.layer.cornerRadius = min(size.height, size.width) / 2
        return ballView
    }()
    
    private lazy var paddleView : UIView = {
        let size = self.breakoutModel.paddleSize
        let origin = CGPoint(x: self.gameView.bounds.midX - size.width / 2, y: self.gameView.bounds.height - 2 * size.height)
        let rect = CGRect(origin: origin, size: size)
        var paddleView = UIView(frame: rect)
        paddleView.backgroundColor = UIColor.blueColor()
        return paddleView
    }()
    
    
    private var breakoutBehavior = BreakoutBehavior()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicAnimator.addBehavior(breakoutBehavior)


    }
    
    override func viewDidLayoutSubviews() {
        breakoutBehavior.addItem(ballView)
        gameView.addSubview(paddleView)
        

        breakoutBehavior.addCollisionBoundaryOfViewFrame(paddleIdentifier, viewItem: paddleView)
        
        
        let pushBehavior = UIPushBehavior(items: [ballView], mode: .Instantaneous)
        pushBehavior.setAngle(CGFloat(-M_PI_4), magnitude: 0.5)
        pushBehavior.action = { [unowned pushBehavior] in
            self.dynamicAnimator.removeBehavior(pushBehavior)
        }
        dynamicAnimator.addBehavior(pushBehavior)

    }
    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        if sender.state == .Ended{
            
        }
    }
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            fallthrough
        case .Changed:
            let point = sender.locationInView(gameView)
            if ( point.x > paddleView.bounds.size.width / 2 && point.x < gameView.bounds.width - paddleView.bounds.size.width / 2 ){
            self.paddleView.center.x = point.x
            self.breakoutBehavior.moveCollisionBoundaryOfViewFrame(self.paddleIdentifier, viewItem: self.paddleView)
            }
        default:
            break
        }
    }
}


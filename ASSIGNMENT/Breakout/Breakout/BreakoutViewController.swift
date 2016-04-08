//
//  ViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit


class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    private var gameStart = false
    
    let breakoutModel = BreakoutModel()
    
    private var ballView : UIImageView!
    
    private var paddleView : UIImageView!
    
    let paddleIdentifier = "paddle"

    @IBOutlet weak var gameView: UIView!
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return dynamicAnimator
    }()
    
    var numberOfBricksLeft = 0
    
    private lazy var breakoutBehavior : BreakoutBehavior = {
        let breakoutBehavior = BreakoutBehavior()
        breakoutBehavior.collisonDelegate = self
        return breakoutBehavior
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicAnimator.addBehavior(breakoutBehavior)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gameStart = false
        setupPaddleView()
        setupBallView()
        setupBrickes()

    }
    
    private func setupBrickes(){
        numberOfBricksLeft = 0
        for i in 0 ..< breakoutModel.numberOfTotalBricks{
            if let oldBrickView = gameView.viewWithTag(i + 1){
                oldBrickView.removeFromSuperview()
                breakoutBehavior.removeCollisonBoundaryWithIdentifier("\(i)")
            }
        }
        for i in 0 ..< breakoutModel.numberOfTotalBricks{
            let brickRowWidth = gameView.bounds.width * CGFloat(breakoutModel.widthRatioatioOfBricksOverContainer)
            let brickRowOffsetX = gameView.bounds.width * CGFloat(0.5 - 0.5 * breakoutModel.widthRatioatioOfBricksOverContainer)
                                  - CGFloat(breakoutModel.numberOfBricksPerRow - 1) * breakoutModel.gapBetweenBricks * CGFloat(0.5)
            
            let brickWidth = brickRowWidth / CGFloat(breakoutModel.numberOfBricksPerRow)
            let x = (brickWidth + breakoutModel.gapBetweenBricks) * CGFloat(( i % breakoutModel.numberOfBricksPerRow)) + brickRowOffsetX
            let y = (breakoutModel.brickHeight + breakoutModel.gapBetweenBricks) * CGFloat(( i / breakoutModel.numberOfBricksPerRow))
                    + breakoutModel.bricksDistanceToTop
            let origin  = CGPoint(x: x, y: y)
            
            let brickSize = CGSize(width: brickWidth,
                                   height: breakoutModel.brickHeight)
            let rect = CGRect(origin: origin, size: brickSize)
            let brickView = UIImageView(frame: rect)
            brickView.image = UIImage(named: "brick \((i / breakoutModel.numberOfBricksPerRow) + 1 )")
            
            brickView.layer.cornerRadius = breakoutModel.bricksCornerRadius
            brickView.layer.masksToBounds = true
            gameView.addSubview(brickView)
            brickView.tag = i + 1 // because default tag value is 0, lets start from 1
            breakoutBehavior.addCollisionBoundaryOfViewFrame("\(i)", viewItem: brickView)
        }
        numberOfBricksLeft = breakoutModel.numberOfTotalBricks
    }
    
    private func setupBallView() {
        if ballView != nil {
            breakoutBehavior.removeItem(ballView)
        }
        let size = breakoutModel.ballSize
        let origin = CGPoint(x: gameView.bounds.midX - size.width / 2,
                             y: paddleView.frame.origin.y - size.height )
        let rect = CGRect(origin: origin, size: size)
        ballView = UIImageView(frame: rect)
        ballView.image = UIImage(named: "ball")
        ballView.layer.cornerRadius = min(size.height, size.width) / 2
        ballView.layer.masksToBounds = true
        breakoutBehavior.addItem(ballView)
    }
    
    private func setupPaddleView(){
        if paddleView != nil{
            paddleView.removeFromSuperview()
            breakoutBehavior.removeCollisonBoundaryWithIdentifier(paddleIdentifier)
        }
        let size = breakoutModel.paddleSize
        let origin = CGPoint(x: gameView.bounds.midX - size.width / 2,
                             y: gameView.bounds.height - breakoutModel.paddleDistanceToBottom)
        let rect = CGRect(origin: origin, size: size)
        
        
        paddleView = UIImageView(frame: rect)
        paddleView.image = UIImage(named: "paddle")
        paddleView.layer.cornerRadius = breakoutModel.paddleCornerRadius
        paddleView.layer.masksToBounds = true
        gameView.addSubview(paddleView)
        breakoutBehavior.addCollisionBoundaryOfViewFrame(paddleIdentifier,
                                                         viewItem: paddleView)
    }
    
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let boundaryIdentifier = identifier as? String{
            if let brickIndex = Int(boundaryIdentifier){
                if 0..<breakoutModel.numberOfTotalBricks ~= brickIndex {
                    breakoutBehavior.removeCollisonBoundaryWithIdentifier(boundaryIdentifier)
                    let hitBrick = gameView.viewWithTag(brickIndex + 1)!
                    
                    // change position
                    UIView.animateWithDuration(0.08, delay: 0, options: [.Repeat, .Autoreverse, .CurveEaseInOut], animations: {
                        hitBrick.center.y += 2
                        }, completion: nil)
                        
                    // change alpha
                    UIView.animateKeyframesWithDuration(0.9, delay: 0.0, options: .BeginFromCurrentState, animations: {
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.15, animations: {
                            hitBrick.alpha = 0
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.15, relativeDuration: 0.15, animations: {
                            hitBrick.alpha = 1
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.6, animations: {
                            hitBrick.alpha = 0
                        })
                        }, completion: { _ in
                            hitBrick.removeFromSuperview()
                    })
                    numberOfBricksLeft -= 1
                    if numberOfBricksLeft == 0 {
                        gameComplete()
                    }
                }
            }
        }
    }
    
    // callback when player success to break all bricks
    func gameComplete(){
       print("Congratuation!")
    }
    
    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        if sender.state == .Ended{
            let pushBehavior = UIPushBehavior(items: [ballView], mode: .Instantaneous)
            pushBehavior.setAngle(CGFloat(-M_PI_4), magnitude: 0.5)
            pushBehavior.action = { [unowned pushBehavior] in
                self.dynamicAnimator.removeBehavior(pushBehavior)
            }
            dynamicAnimator.addBehavior(pushBehavior)
            gameStart = true
        }
    }
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            fallthrough
        case .Changed:
            if gameStart == false{
                break
            }
            
            let point = sender.locationInView(gameView)
            if ( point.x > paddleView.bounds.size.width / 2
                && point.x < gameView.bounds.width - paddleView.bounds.size.width / 2 ){
            paddleView.center.x = point.x
            breakoutBehavior.moveCollisionBoundaryOfViewFrame(paddleIdentifier, viewItem: paddleView)
            }
        
        default:
            break
        }
    }
}


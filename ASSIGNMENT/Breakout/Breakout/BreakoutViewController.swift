//
//  ViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit


class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    let breakoutModel = BreakoutModel()
    
    let paddleIdentifier = "paddle"

    @IBOutlet weak var gameView: UIView!
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return dynamicAnimator
    }()
    
    var numberOfBricksLeft = 0
    
    

    
    private var ballView : UIView!{
        willSet{
            print("warning")
        }
    }
    
    private var paddleView : UIView!
    
    
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
        
        setupBallView()
        setupPaddleView()
        setupBrickes()

    }
    
    private func setupBrickes(){
        for i in 0 ..< (breakoutModel.numberOfBricksPerRow * breakoutModel.numberOfBrickRows){
            if let oldBrickView = gameView.viewWithTag(i + 1){
                oldBrickView.removeFromSuperview()
                breakoutBehavior.removeCollisonBoundaryWithIdentifier("\(i)")
            }
        }
        for i in 0 ..< (breakoutModel.numberOfBricksPerRow * breakoutModel.numberOfBrickRows){
            let brickWidth = gameView.bounds.width / CGFloat(breakoutModel.numberOfBricksPerRow)
            let x = brickWidth * CGFloat(( i % breakoutModel.numberOfBricksPerRow))
            let y = breakoutModel.brickHeight * CGFloat(( i / breakoutModel.numberOfBricksPerRow))
                    + breakoutModel.bricksDistanceToTop
            let origin  = CGPoint(x: x, y: y)
            let hue = 1.0 / CGFloat(breakoutModel.numberOfBrickRows) * CGFloat(i / breakoutModel.numberOfBrickRows)
            let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            let brickView = createBreakAt(origin, color: color)
            brickView.layer.cornerRadius = breakoutModel.bricksCornerRadius
            gameView.addSubview(brickView)
            brickView.tag = i + 1 // because default tag value is 0, lets start from 1
            numberOfBricksLeft += 1
            breakoutBehavior.addCollisionBoundaryOfViewFrame("\(i)", viewItem: brickView)
        }
    }
    
    private func setupBallView() {
        if ballView != nil {
            breakoutBehavior.removeItem(ballView)
        }
        let size = breakoutModel.ballSize
        let origin = CGPoint(x: gameView.bounds.midX - size.width / 2,
                             y: gameView.bounds.midY - size.height / 2)
        let rect = CGRect(origin: origin, size: size)
        ballView = UIView(frame: rect)
        ballView.backgroundColor = UIColor.darkGrayColor()
        ballView.layer.cornerRadius = min(size.height, size.width) / 2
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
        
        
        paddleView = UIView(frame: rect)
        paddleView.backgroundColor = UIColor.blueColor()
        gameView.addSubview(paddleView)
        breakoutBehavior.addCollisionBoundaryOfViewFrame(paddleIdentifier,
                                                         viewItem: paddleView)
    }
    
    private func createBreakAt( origin: CGPoint, color: UIColor) -> UIView{
        let gameViewWidth = gameView.bounds.width
        let brickWidth = gameViewWidth / CGFloat(breakoutModel.numberOfBricksPerRow) - breakoutModel.gapBetweenBricks
        let brickSize = CGSize(width: brickWidth,
                               height: breakoutModel.brickHeight - breakoutModel.gapBetweenBricks)
        let rect = CGRect(origin: origin, size: brickSize)
        let brickView = UIView(frame: rect)
        brickView.backgroundColor = color
        return brickView
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let boundaryIdentifier = identifier as? String{
            if let brickIndex = Int(boundaryIdentifier){
                if 0...24 ~= brickIndex {
                    breakoutBehavior.removeCollisonBoundaryWithIdentifier(boundaryIdentifier)
                    let hitBrick = gameView.viewWithTag(brickIndex + 1)!
                    UIView.animateKeyframesWithDuration(1.2, delay: 0.0, options: .CalculationModeLinear, animations: {
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: {
                            hitBrick.backgroundColor = UIColor.whiteColor()
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3, animations: {
                            hitBrick.backgroundColor = UIColor.darkGrayColor()
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.6, animations: {
                            hitBrick.backgroundColor = UIColor.lightGrayColor()
                            hitBrick.alpha = 0.0
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
        }
    }
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            fallthrough
        case .Changed:
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


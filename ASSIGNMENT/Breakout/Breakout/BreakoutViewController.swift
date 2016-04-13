//
//  ViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import CoreMotion


class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    
    private var gameStart = false
    
    let breakoutModel = BreakoutModel()
    
    var ballCount = 0
    var pushCount = 0
    
    private var paddleView : UIImageView!
    
    let paddleIdentifier = "paddle"
    

    @IBOutlet weak var gameView: UIView!
    
    private lazy var dynamicAnimator: UIDynamicAnimator = {
        let dynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return dynamicAnimator
    }()
    
    var numberOfBricksLeft = 0
    
    var hitBricks = [Int]()
    
    private var xOfPaddle:CGFloat  {
        get{
            return self.paddleView.center.x
        }
        set{
            if gameStart == true {
                let oldValue = self.paddleView.center.x
                if ( newValue > paddleView.bounds.size.width / 2
                    && newValue < gameView.bounds.width - paddleView.bounds.size.width / 2 ){
                    movePaddleViewWithAnimationTo(newValue)
                }
                else if( oldValue > paddleView.bounds.size.width / 2
                    && newValue <= paddleView.bounds.size.width / 2){
                    movePaddleViewWithAnimationTo(self.paddleView.bounds.size.width / 2)
                }
                else if( oldValue < gameView.bounds.width - paddleView.bounds.size.width / 2
                    && newValue >=  gameView.bounds.width - paddleView.bounds.size.width / 2){
                    movePaddleViewWithAnimationTo(self.gameView.bounds.width - self.paddleView.bounds.size.width / 2)
                }
            }
        }
    }
    
    private let motionUpdateInterval = 0.1
    
    
    private lazy var breakoutBehavior : BreakoutBehavior = {
        let breakoutBehavior = BreakoutBehavior()
        breakoutBehavior.collisonDelegate = self
        return breakoutBehavior
    }()
    
    
    private let motionManager : CMMotionManager = {
        let manager = AppDelegate.Motion.manager
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicAnimator.addBehavior(breakoutBehavior)
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        initGame()
        
        motionManager.deviceMotionUpdateInterval = motionUpdateInterval
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue())
        { (data, _) in
            if self.breakoutModel.controlMode == ControlMode.attitude{
                let gravity = (data!.gravity)
                let deviceAngle =  CGFloat(-atan(gravity.x / gravity.y) * 180 / M_PI )
                
                    self.xOfPaddle = self.gameView.center.x + 4 * deviceAngle
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        motionManager.stopDeviceMotionUpdates()
        removeAllBallViews()
    }
    
    private func initGame(){
        gameStart = false
        setupPaddleView()
        setupBallView()
        setupBrickes()
    }
    
    private func setupBrickes(){
        let maximumBricksCount = breakoutModel.numberOfBricksPerRow * BreakoutModel.maximumOfBrickRow
        for i in 0 ..< maximumBricksCount{
            if let oldBrickView = gameView.viewWithTag(i + 1){
                oldBrickView.removeFromSuperview()
                breakoutBehavior.removeCollisonBoundaryWithIdentifier("\(i)")
            }
        }
        numberOfBricksLeft = 0
        hitBricks.removeAll()
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
            numberOfBricksLeft += 1
            breakoutBehavior.addCollisionBoundaryOfViewFrame("\(i)", viewItem: brickView)
        }
    }
    
    private func movePaddleViewWithAnimationTo( x: CGFloat){
        UIView.animateWithDuration(motionUpdateInterval, animations: {
            self.paddleView.center.x = x
        })
        breakoutBehavior.moveCollisionBoundaryOfViewFrame(paddleIdentifier, viewItem: paddleView)
    }
    
    private func setupBallView() {
        removeAllBallViews()
        addABall()
    }
    
    private func removeAllBallViews(){
        for i in breakoutModel.minOfBallViewTag...breakoutModel.maxOfBallViewTag{
            if let ballView = gameView.viewWithTag(i){
                breakoutBehavior.removeItem(ballView)
            }
        }
        ballCount = 0
    }
    
    private func addABall(){
        
        let size = breakoutModel.ballSize
        let origin = CGPoint(x: paddleView.center.x - size.width / 2,
                             y: paddleView.frame.origin.y - size.height)
        let rect = CGRect(origin: origin, size: size)
        let ballView = UIImageView(frame: rect)
        ballCount += 1
        ballView.tag = breakoutModel.baseOfBallViewTag + ballCount
        ballView.image = UIImage(named: "ball")
        ballView.layer.cornerRadius = min(size.height, size.width) / 2
        ballView.layer.masksToBounds = true
        gameView.addSubview(ballView)
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
                if hitBricks.contains(brickIndex){
                    return
                }
                if 0..<breakoutModel.numberOfTotalBricks ~= brickIndex {
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
                            self.breakoutBehavior.removeCollisonBoundaryWithIdentifier(boundaryIdentifier)
                    })
                    
                    hitBricks.append(brickIndex)
                    print(brickIndex)
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
        let alert =  UIAlertController(title: nil, message: "Congratuation!", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel){ _ in
            self.initGame()
        }
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        if sender.state == .Ended{
            if gameStart == false{
                gameStart = true
                pushCount = 0
            }
            if pushCount < breakoutModel.ballCount{
                let ballView = gameView.viewWithTag(breakoutModel.baseOfBallViewTag + ballCount)!
                let pushBehavior = UIPushBehavior(items: [ballView], mode: .Instantaneous)
                let pushMagnitude = CGFloat(breakoutModel.bounciness)
                pushBehavior.setAngle(CGFloat(-M_PI_4), magnitude: pushMagnitude)
                pushBehavior.action = { [unowned pushBehavior] in
                    self.dynamicAnimator.removeBehavior(pushBehavior)
                }
                dynamicAnimator.addBehavior(pushBehavior)
                breakoutBehavior.addItem(ballView)
                if ballCount < breakoutModel.ballCount{
                    addABall()
                }
            }
            pushCount += 1
        }
    }
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        if breakoutModel.controlMode == ControlMode.panGesture{
            switch sender.state {
            case .Began:
                fallthrough
            case .Changed:
                
                let point = sender.locationInView(gameView)
                xOfPaddle = point.x
            default:
                break
            }
        }
    }
    
    
}


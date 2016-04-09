//
//  ViewController.swift
//  CoreMotionDemo
//
//  Created by Junyang ma on 4/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let manager = AppDelegate.Motion.manager
        manager.deviceMotionUpdateInterval = 0.1
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue())
        { (data, _) in
            let gravity = (data!.gravity)
            let angle =  atan(gravity.x / gravity.y) * 180 / M_PI
            
            print(angle)
        }
        
    }
    



}


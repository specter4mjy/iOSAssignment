//
//  ViewController.swift
//  CoreMotionDemo
//
//  Created by Junyang ma on 4/9/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {

    let manager = AppDelegate.Motion.manager
    
    var cubeNode: SCNNode = {
        let cube = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let node = SCNNode(geometry: cube)
        return node
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let sceneView = SCNView(frame: view.frame)
        view.addSubview(sceneView)
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3( 0, 0, 3)
        
        let light = SCNLight()
        light.type = SCNLightTypeOmni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
        
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cubeNode)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        manager.deviceMotionUpdateInterval = 0.01
        manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue())
        { (data, _) in
            let pitch = data!.attitude.pitch
            let roll = data!.attitude.roll
            let yaw = data!.attitude.yaw
            
            print("pitch \(pitch * 180 / M_PI) roll \(roll * 180 / M_PI) yaw \(yaw * 180 / M_PI) ")
            
            
            // useing eulerAngle
            self.cubeNode.eulerAngles.x = Float(pitch)
            self.cubeNode.eulerAngles.y = Float(roll)
            self.cubeNode.eulerAngles.z = Float(yaw)
            
            // using quaternion
//            let x = data!.attitude.quaternion.x
//            let y = data!.attitude.quaternion.y
//            let z = data!.attitude.quaternion.z
//            let w = data!.attitude.quaternion.w
//            self.cubeNode.orientation = SCNQuaternion(x, y, z, w)
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        manager.stopDeviceMotionUpdates()
    }
    



}


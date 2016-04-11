//
//  ViewController.swift
//  WatchOSDemo
//
//  Created by Junyang ma on 4/11/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController,WCSessionDelegate {

    @IBOutlet weak var countLabel: UILabel!
    private var session :WCSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        if WCSession.isSupported(){
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let countValue = message["count"] as? String{
            dispatch_sync(dispatch_get_main_queue(), {
                self.countLabel.text = countValue
                print(message)
            })
        }
    }



}


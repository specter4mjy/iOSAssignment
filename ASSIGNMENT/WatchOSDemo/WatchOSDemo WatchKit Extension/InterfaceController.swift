//
//  InterfaceController.swift
//  WatchOSDemo WatchKit Extension
//
//  Created by Junyang ma on 4/11/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var countLabel: WKInterfaceLabel!
    
    private var session: WCSession?
    
    private var countValue = 0 {
        didSet{
            countLabel.setText(countValue.description)
            if session != nil{
                session!.sendMessage(["count":countValue.description], replyHandler: nil, errorHandler: nil)
            }
        }
    }
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        if WCSession.isSupported(){
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBAction func minusCount() {
        countValue -= 1
    }
    @IBAction func addCount() {
        countValue += 1
    }

}

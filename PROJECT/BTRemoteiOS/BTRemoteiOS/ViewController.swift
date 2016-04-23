//
//  ViewController.swift
//  BTRemoteiOS
//
//  Created by Junyang ma on 4/22/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBPeripheralManagerDelegate {
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let cursorPositionUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let arrowKeyUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var myPeripheralManager : CBPeripheralManager!
    var cursorPositionCharacteristic : CBMutableCharacteristic!
    var arrowKeyCharacteristic : CBMutableCharacteristic!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            setupPeripheral()
    }


    // MARK: iPhone - Peripheral Manager
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn{
            print("peripheral power on")
            cursorPositionCharacteristic = CBMutableCharacteristic(type: cursorPositionUUID, properties: [.Read,.Notify], value: nil, permissions: .Readable)
            arrowKeyCharacteristic = CBMutableCharacteristic(type: arrowKeyUUID, properties: [.Read,.Notify], value: nil, permissions: .Readable)
            let myService = CBMutableService(type: myServiceUUID, primary:true)
            myService.characteristics = [cursorPositionCharacteristic, arrowKeyCharacteristic]
            myPeripheralManager.addService(myService)
            let advertisingData : [ String : AnyObject] = [
                CBAdvertisementDataServiceUUIDsKey : [myServiceUUID]
            ]
            myPeripheralManager.startAdvertising(advertisingData)
        }
        else{
            print("peripheral not power on")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        print("add service")
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error == nil {
            print("start Advertising")
        }
        else {
            print(error)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print(" did subscribe characteristic")
    }
    
    @IBAction func panGestureHangler(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(view)
        print(point)
        var xOfPoint = Double(point.x)
        var yOfPoint = Double(point.y)
        let cursorData = NSMutableData()
        cursorData.appendBytes(&xOfPoint, length: sizeof(Double))
        cursorData.appendBytes(&yOfPoint, length: sizeof(Double))
        myPeripheralManager.updateValue(cursorData, forCharacteristic: cursorPositionCharacteristic, onSubscribedCentrals: nil)
//        myPeripheralManager.updateValue(yData, forCharacteristic: yOfPointCharacteristic, onSubscribedCentrals: nil)
    }

    @IBAction func arrowKeys(sender: UIButton) {
        if let title = sender.titleLabel?.text{
            let data = title.dataUsingEncoding(NSUTF8StringEncoding)
            myPeripheralManager.updateValue(data!, forCharacteristic: arrowKeyCharacteristic, onSubscribedCentrals: nil)
        }
    }
}


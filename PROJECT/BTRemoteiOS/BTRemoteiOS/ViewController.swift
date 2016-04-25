//
//  ViewController.swift
//  BTRemoteiOS
//
//  Created by Junyang ma on 4/22/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import CoreBluetooth
import MediaPlayer

enum VolumeKeys {
    case up, down
}

class ViewController: UIViewController,CBPeripheralManagerDelegate {
    
    @IBOutlet weak var trackpadView: UIImageView!
    // Bluetooth properties
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let cursorPositionUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let arrowKeyUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var myPeripheralManager : CBPeripheralManager!
    var cursorPositionCharacteristic : CBMutableCharacteristic!
    var arrowKeyCharacteristic : CBMutableCharacteristic!
    
    
    // volume button properties
    var systemOutputVolume  : Float {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.systemOutputVolume
    }
    
    var volumeView :MPVolumeView!
    
    var restoreVolume = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupPeripheral()
//        UIScreen.mainScreen().brightness = 0
        hideSystemVolumeHUD()
    }
    
    
    // MART: volume vutton
    
    func setSystemOutputValue(value: Float){
        if let slide = volumeView.subviews[1] as? UISlider{
            slide.setValue(value, animated: false)
        }
    }
    
    func hideSystemVolumeHUD(){
        volumeView = MPVolumeView(frame: CGRect(x: 0, y: -100, width: 0, height: 0))
        view.addSubview(volumeView)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print(restoreVolume)
        if keyPath == "outputVolume"{
            
            if ( restoreVolume == true){
                // volume changed caused by setSystemOutputValue method rather by user, so ignore it
                restoreVolume = false
                return
            }
            if let currentVolume = change?["new"] as? Float{
                var key: VolumeKeys
                
                print("current: \(currentVolume) system: \(systemOutputVolume)")
                if currentVolume == systemOutputVolume{
                    key = currentVolume == 1 ? .up : .down
                } else {
                    key = currentVolume > systemOutputVolume ? .up : .down
                    restoreVolume = true
                    setSystemOutputValue(systemOutputVolume)
                }
                
                volumeButtonPressed(key)
            }
        }
    }
    
    func volumeButtonPressed(key : VolumeKeys){
        let keyString = key == .up ? "Previous" : "Next"
        print( keyString)
        let data = keyString.dataUsingEncoding(NSUTF8StringEncoding)
        myPeripheralManager.updateValue(data!, forCharacteristic: arrowKeyCharacteristic, onSubscribedCentrals: nil)
    }


    // MARK: Bluetooth - Peripheral Manager
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
        //        var point = sender.locationInView(view)
        switch sender.state {
        case .Changed:
            let point = sender.translationInView(trackpadView)
            print(point)
            sender.setTranslation(CGPointZero, inView: trackpadView)
            var xOfPoint = Double(point.x)
            var yOfPoint = Double(point.y)
            let cursorData = NSMutableData()
            cursorData.appendBytes(&xOfPoint, length: sizeof(Double))
            cursorData.appendBytes(&yOfPoint, length: sizeof(Double))
            myPeripheralManager.updateValue(cursorData, forCharacteristic: cursorPositionCharacteristic, onSubscribedCentrals: nil)
        default:
            break
        }
        //        myPeripheralManager.updateValue(yData, forCharacteristic: yOfPointCharacteristic, onSubscribedCentrals: nil)
    }

}


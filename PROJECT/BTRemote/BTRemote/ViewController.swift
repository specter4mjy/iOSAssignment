//
//  ViewController.swift
//  BTRemote
//
//  Created by Junyang ma on 4/22/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController,CBCentralManagerDelegate,CBPeripheralDelegate  {
    var myCentralManager : CBCentralManager!
    var myPeripheral : CBPeripheral!
    
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let cursorPosiotnUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let yOfPointUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var cursorPositionCharacteristic : CBMutableCharacteristic!
    var yOfPointCharacteristic : CBMutableCharacteristic!
    
    var cursorPoint : CGPoint = CGPointZero
    

    override func viewDidLoad() {
        super.viewDidLoad()
            setupCentral()

        // Do any additional setup after loading the view.
    }
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: iPad - Central Manager
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn{
            print("central power on")
            myCentralManager.scanForPeripheralsWithServices([myServiceUUID], options: nil)
        }
        else{
            print("central not power on")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(advertisementData)
        myPeripheral = peripheral
        central.connectPeripheral(peripheral, options: nil)
        central.stopScan()
        print(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("peripheral connected")
        peripheral.delegate = self
        peripheral.discoverServices([myServiceUUID])
    }
    
    // MARK: iPad - Peripheral Delegates
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics([cursorPosiotnUUID,yOfPointUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            switch characteristic.UUID {
            case cursorPosiotnUUID: fallthrough
            case yOfPointUUID:
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            default:
                break
            }
            // subscribe value
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(" reading subscribed value has error")
            print( error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value {
            switch characteristic.UUID {
            case cursorPosiotnUUID:
                var x : Double = 0
                data.getBytes(&x, length: sizeof(Double))
                var y : Double = 0
                let range = NSRange(location: sizeof(Double), length: sizeof(Double))
                data.getBytes(&y, range: range)
                cursorPoint = CGPoint(x: x, y: y)
                CGWarpMouseCursorPosition(cursorPoint)
                print(cursorPoint)
            case yOfPointUUID:
                break
            default:
                break
            }
        }
    }
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func test(sender: NSButton) {
        print("button")
//        CGDisplayMoveCursorToPoint(<#T##CGDirectDisplayID#>, <#T##CGPoint#>)
        CGWarpMouseCursorPosition(CGPointMake(300, 300))
    }


}


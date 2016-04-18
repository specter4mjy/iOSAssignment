//
//  ViewController.swift
//  BTReader
//
//  Created by Junyang ma on 4/17/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController,CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    
    let myUuid = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    var myCentralManager : CBCentralManager!
    var myPeripheralManager : CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            setupPeripheral()
        case .Pad:
            setupCentral()
        default:
            break
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == .PoweredOn{
            print("central power on")
            myCentralManager.scanForPeripheralsWithServices([myUuid], options: nil)
        }
        else{
            print("central not power on")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn{
            print("peripheral power on")
            let myData = "specter".dataUsingEncoding(NSUTF8StringEncoding)
            let myCharacteristic = CBMutableCharacteristic(type: myUuid, properties: .Read, value: myData, permissions: .Readable)
            let myService = CBMutableService(type: myUuid, primary:true)
            myService.characteristics?.append(myCharacteristic)
            myPeripheralManager.addService(myService)
            let advertisingData : [ String : AnyObject] = [
                CBAdvertisementDataServiceUUIDsKey : [myUuid]
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
    
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(peripheral)
        print(advertisementData)
        myCentralManager.connectPeripheral(peripheral, options: nil)
        
    }
    
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


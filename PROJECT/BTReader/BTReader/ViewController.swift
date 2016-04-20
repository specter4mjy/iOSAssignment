//
//  ViewController.swift
//  BTReader
//
//  Created by Junyang ma on 4/17/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController,CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UITextViewDelegate {
    
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let myCharacteristiceUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    var myCentralManager : CBCentralManager!
    var myPeripheralManager : CBPeripheralManager!
    var myPeripheral : CBPeripheral!
    
    @IBOutlet weak var iphoneTV: UITextView! {
        didSet{
            iphoneTV.delegate = self
        }
    }
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
            myCentralManager.scanForPeripheralsWithServices([myServiceUUID], options: nil)
        }
        else{
            print("central not power on")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn{
            print("peripheral power on")
            let myData = "specter".dataUsingEncoding(NSUTF8StringEncoding)
            let myCharacteristic = CBMutableCharacteristic(type: myCharacteristiceUUID, properties: .Read, value: myData, permissions: .Readable)
            let myService = CBMutableService(type: myServiceUUID, primary:true)
            myService.characteristics = [myCharacteristic]
            myPeripheralManager.addService(myService)
            let advertisingData : [ String : AnyObject] = [
                CBAdvertisementDataLocalNameKey : "BTReader",
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
    
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
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
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics([myCharacteristiceUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            print(characteristic)
            peripheral.readValueForCharacteristic(characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value {
            if let stringValue = String(data: data, encoding: NSUTF8StringEncoding){
                print(stringValue)
            }
        }
    }
    
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    @IBAction func iphoneSendCurrentText(sender: UIBarButtonItem) {
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(iphoneTV.contentOffset)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


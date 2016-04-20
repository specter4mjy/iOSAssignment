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
    var myIphoneScrollingPositionCharacteristic : CBMutableCharacteristic!
    
    @IBOutlet weak var iphoneTV: UITextView! {
        didSet{
            iphoneTV.delegate = self
        }
    }
    @IBOutlet weak var iPadTV: UITextView!
    
    
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
    
    
    
    // MARK: iPad - Central Manager
    
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
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
            peripheral.discoverCharacteristics([myCharacteristiceUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            print(characteristic)
            // redaing value
//            peripheral.readvalueforcharacteristic(characteristic)
            // subscribe value
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(" reading subscribed value has error")
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value {
            var value : Float = 0
            data.getBytes(&value, length: sizeof(Float))
//            print(value)
            let offsetPoint = CGPoint(x: 0, y: Double(value))
            iPadTV.setContentOffset(offsetPoint, animated: false)
        }
    }
    
    // MARK: iPhone - Peripheral Manager
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn{
            print("peripheral power on")
            myIphoneScrollingPositionCharacteristic = CBMutableCharacteristic(type: myCharacteristiceUUID, properties: [.Read,.Notify], value: nil, permissions: .Readable)
            let myService = CBMutableService(type: myServiceUUID, primary:true)
            myService.characteristics = [myIphoneScrollingPositionCharacteristic]
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
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print(" did subscribe characteristic")
    }
    
    
    
    
    @IBAction func iphoneSendCurrentText(sender: UIBarButtonItem) {
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var floatData = Float(iphoneTV.contentOffset.y)
        let myData = NSData(bytes: &floatData, length: sizeof(Float))
        myPeripheralManager.updateValue(myData, forCharacteristic: myIphoneScrollingPositionCharacteristic, onSubscribedCentrals: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


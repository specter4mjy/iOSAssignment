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
    let myIphoneScrollingPositionCharacteristicUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let myIphoneContentHeightUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var myCentralManager : CBCentralManager!
    var myPeripheralManager : CBPeripheralManager!
    var myPeripheral : CBPeripheral!
    var myIphoneScrollingPositionCharacteristic : CBMutableCharacteristic!
    var myIphoneContentHeightCharacteristic : CBMutableCharacteristic!
    var myIphoneContentHeight : CGFloat = 0
    
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
            peripheral.discoverCharacteristics([myIphoneScrollingPositionCharacteristicUUID,myIphoneContentHeightUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            switch characteristic.UUID {
            case myIphoneContentHeightUUID:
                peripheral.readValueForCharacteristic(characteristic)
            case myIphoneScrollingPositionCharacteristicUUID:
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
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value {
            var value : Double = 0
            data.getBytes(&value, length: sizeof(Double))
            switch characteristic.UUID {
            case myIphoneContentHeightUUID:
                myIphoneContentHeight = CGFloat(value)
            case myIphoneScrollingPositionCharacteristicUUID:
                //            print(value)
                if ( myIphoneContentHeight > 0){
                    let iPadContentHeight = iPadTV.contentSize.height
                    print(iPadContentHeight)
                    print(value)
                    print(iPadTV.contentOffset)
                    let contentHeightRatio = Double(iPadContentHeight / myIphoneContentHeight)
                    let offsetPoint = CGPoint(x: 0, y: value / contentHeightRatio)
                    print(contentHeightRatio)
//                    print(offsetPoint.y)
                    iPadTV.setContentOffset(offsetPoint, animated: false)
                }
            default:
                break
            }
        }
    }
    
    // MARK: iPhone - Peripheral Manager
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn{
            print("peripheral power on")
            myIphoneScrollingPositionCharacteristic = CBMutableCharacteristic(type: myIphoneScrollingPositionCharacteristicUUID, properties: [.Read,.Notify], value: nil, permissions: .Readable)
            var contentHeight = Double(iphoneTV.contentSize.height)
            let myHeightData = NSData(bytes: &contentHeight, length: sizeof(Double))
            myIphoneContentHeightCharacteristic = CBMutableCharacteristic(type: myIphoneContentHeightUUID, properties: .Read, value: myHeightData, permissions: .Readable)
            let myService = CBMutableService(type: myServiceUUID, primary:true)
            myService.characteristics = [myIphoneScrollingPositionCharacteristic, myIphoneContentHeightCharacteristic]
            myPeripheralManager.addService(myService)
            let advertisingData : [ String : AnyObject] = [
                CBAdvertisementDataLocalNameKey : "BTReader",
                CBAdvertisementDataServiceUUIDsKey : [myServiceUUID]
            ]
            myPeripheralManager.startAdvertising(advertisingData)
        }
        else{1
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
        print(iphoneTV.contentSize)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var floatData = Double(iphoneTV.contentOffset.y)
        let myData = NSData(bytes: &floatData, length: sizeof(Double))
        myPeripheralManager.updateValue(myData, forCharacteristic: myIphoneScrollingPositionCharacteristic, onSubscribedCentrals: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


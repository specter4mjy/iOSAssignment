//
//  AppDelegate.swift
//  BTRemoteMac
//
//  Created by Junyang ma on 4/23/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import Cocoa
import CoreBluetooth
import CoreGraphics

enum VirtualKeys: UInt16 {
    case left = 0x7b
    case right = 0x7c
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate {

    var myCentralManager : CBCentralManager!
    var myPeripheral : CBPeripheral!
    
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let cursorPosiotnUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let arrowKeyUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var cursorPositionCharacteristic : CBMutableCharacteristic!
    var arrowKeyCharacteristic : CBMutableCharacteristic!
    
    let screenHeight = NSScreen.screens()!.first!.frame.height
    

    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        if let button = statusItem.button{
            button.image = NSImage(named: "icon")
        }
        statusItem.menu = statusMenu
        
        setupCentral()
    }
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK:  Central Manager
    
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
    
    // MARK:  Peripheral Delegates
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics([cursorPosiotnUUID,arrowKeyUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            peripheral.setNotifyValue(true, forCharacteristic: characteristic)
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print( characteristic.UUID)
            print(" reading subscribed value has error \n erro is :")
            print( error)
            print("error end")
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
//                CGWarpMouseCursorPosition(cursorPoint)
                var cursorPoint = NSEvent.mouseLocation()
                cursorPoint.y = screenHeight - cursorPoint.y
                cursorPoint.x += CGFloat(x)
                cursorPoint.y += CGFloat(y)
                CGWarpMouseCursorPosition(cursorPoint)
                print("x: \(x) y: \(y)")
            case arrowKeyUUID:
                let text = String(data: data, encoding: NSUTF8StringEncoding)!
                print(text)
                switch text {
                case "Previous":
                    createKeyCode(.left)
                case "Next":
                    createKeyCode(.right)
                default:
                    break
                }
                break
            default:
                break
            }
        }
    }
    
    func createKeyCode( key: VirtualKeys){
        let source = CGEventSourceCreate(.HIDSystemState)
        let rightPressed = CGEventCreateKeyboardEvent(source, key.rawValue, true)
        CGEventPost(.CGHIDEventTap, rightPressed)
        let rightReleased = CGEventCreateKeyboardEvent(source, key.rawValue, false)
        CGEventPost(.CGHIDEventTap, rightReleased)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

}


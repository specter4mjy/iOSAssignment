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
    
    let screenHeight = NSScreen.screens.first!.frame.height
    

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var connectStateMenuItem: NSMenuItem!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button{
            button.image = NSImage(named: NSImage.Name(rawValue: "icon"))
        }
        statusItem.menu = statusMenu
        
        setupCentral()
    }
    private func setupCentral(){
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK:  Central Manager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            print("central power on")
            myCentralManager.scanForPeripherals(withServices: [myServiceUUID], options: nil)
        }
        else{
            print("central not power on")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        myPeripheral = peripheral
        central.connect(peripheral, options: nil)
        print(peripheral)
        central.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral connected")
        peripheral.delegate = self
        peripheral.discoverServices([myServiceUUID])
        if let title = peripheral.name {
            connectStateMenuItem.title = "\(title) Connected"
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        connectStateMenuItem.title = "Scanning..."
        myCentralManager.scanForPeripherals(withServices: [myServiceUUID], options: nil)
    }
    
    // MARK:  Peripheral Delegates
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print(service)
            peripheral.discoverCharacteristics([cursorPosiotnUUID,arrowKeyUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovered Characteristic")
        for characteristic in service.characteristics!{
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print( characteristic.uuid)
            print(" reading subscribed value has error \n erro is :")
            print( error!)
            print("error end")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            switch characteristic.uuid {
            case cursorPosiotnUUID:
                var x : Double = 0
                var bytes = [UInt8](repeating:0, count: 2 * MemoryLayout<Double>.size)
                data.copyBytes(to: &bytes, count: 2 * MemoryLayout<Double>.size)
                let xData = Data(bytes: bytes[0..<MemoryLayout<Double>.size])
                x = xData.withUnsafeBytes { $0.pointee }
                var y : Double = 0
                let yData = Data(bytes: bytes[MemoryLayout<Double>.size..<2 * MemoryLayout<Double>.size])
                y = yData.withUnsafeBytes { $0.pointee }
                var cursorPoint = NSEvent.mouseLocation
                cursorPoint.y = screenHeight - cursorPoint.y
                cursorPoint.x += CGFloat(x)
                cursorPoint.y += CGFloat(y)
                CGWarpMouseCursorPosition(cursorPoint)
                print("x: \(x) y: \(y)")
            case arrowKeyUUID:
                let text = String(data: data, encoding: String.Encoding.utf8)!
                print(text)
                switch text {
                case "Previous":
                    createKeyCode(key: .left)
                case "Next":
                    createKeyCode(key: .right)
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
        let source = CGEventSource(stateID: .hidSystemState)
        let rightPressed = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: true)
        
        rightPressed?.post(tap: .cghidEventTap)
        let rightReleased = CGEvent(keyboardEventSource: source, virtualKey: key.rawValue, keyDown: false)
        rightReleased?.post(tap: .cghidEventTap)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

}


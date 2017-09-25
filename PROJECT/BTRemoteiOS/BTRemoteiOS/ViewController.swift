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
    @IBOutlet weak var speedSlider: UISlider! {
        didSet{
            speedSlider.value = cursorSpeed
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
            speedSlider.transform = rotateTransform
            speedSlider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    
    lazy var settingViews : [UIView] = {
        var views = [UIView]()
        views.append(self.speedSlider)
        views.append(self.stackView)
        return views
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // Bluetooth properties
    let myServiceUUID = CBUUID(string: "5CB39A21-3310-4A2E-B46E-8F6F3ABDA6CD")
    let cursorPositionUUID = CBUUID(string: "72ACF398-5A19-458C-83EB-01194E1AA533")
    let arrowKeyUUID = CBUUID(string: "546B3FE8-255F-4F69-A154-D3057CCF0499")
    var myPeripheralManager : CBPeripheralManager!
    var cursorPositionCharacteristic : CBMutableCharacteristic!
    var arrowKeyCharacteristic : CBMutableCharacteristic!
    
    var gestureFingerNumber = 0
    
    let trackpadCenterOffset:CGFloat = 4
    
    // volume button properties
    let audioSession = AVAudioSession.sharedInstance()
    
    var systemOutputVolume: Float = 0.5
    var systemBrightness: CGFloat = 0.5
    var brightnessState: BrightnessState = .on
    
    var cursorSpeed: Float  {
        get{
            let defaults = UserDefaults.standard
            var cursorSpeedValue = defaults.float(forKey: "cursorSpeed")
            if cursorSpeedValue == 0 {
                cursorSpeedValue = 1
            }
            return cursorSpeedValue
        }
        set{
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "cursorSpeed")
            speedSlider.value = newValue
        }
    }
    
    
    var volumeView :MPVolumeView!
    
    var restoreVolume = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPeripheral()
        hideSystemVolumeHUD()
        bindApplicationLifeCycleNotifications()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupElementsLocation()
    }
    
    
    func setupElementsLocation(){
        speedSlider.center.x += 2
        let currentTrackpadCenterX = trackpadView.center.x - trackpadCenterOffset
        let screenCenterX = view.center.x
        let distence = screenCenterX - currentTrackpadCenterX
        moveSettingViewsXBy(x: distence)
    }
    func moveSettingViewsXBy(x: CGFloat){
        let targetTrackpadOriginX = trackpadView.frame.origin.x + x
        let targetTrackpadCenterX = trackpadView.center.x - trackpadCenterOffset + x
        let screenCenterX = view.center.x 
        if (targetTrackpadOriginX < 0) || (targetTrackpadCenterX > screenCenterX ){
            return
        }
        trackpadView.center.x += x
        for view in settingViews{
            view.center.x += x * 2
        }
    }
    
    func rearrangeSettingViewsAfterPanGesture(){
        let currentTrackpadOriginX = trackpadView.frame.origin.x
        let currentTrackpadCenterX = trackpadView.center.x - trackpadCenterOffset
        let screenCenterX = view.center.x
        let leftDistence = currentTrackpadOriginX
        let rightDistence = screenCenterX - currentTrackpadCenterX
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            if leftDistence > rightDistence {
                self.moveSettingViewsXBy(x: rightDistence)
            }else{
                self.moveSettingViewsXBy(x: -leftDistence)
            }
            }, completion: nil)
    }
    
    // MART: volume button
    
    func bindApplicationLifeCycleNotifications(){
        let center = NotificationCenter.default
        
        center.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: appActive)
        center.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil, using: appResignActive)
    }
    
    func appActive(note : Notification){
        addVolumeChangeObserver()
        systemBrightness = UIScreen.main.brightness
        if brightnessState == .off {
            UIScreen.main.brightness =  0
        }
    }
    
    func appResignActive(note : Notification){
        removeVolumeChangeObserver()
        UIScreen.main.brightness = systemBrightness
        
    }
    
    func addVolumeChangeObserver(){
        systemOutputVolume = audioSession.outputVolume
        switch systemOutputVolume {
        case 0:
            systemOutputVolume = 0.01
        case 1:
            systemOutputVolume = 0.99
        default:
            break
        }
        setSystemOutputValue(value: systemOutputVolume)
        do{
            try audioSession.setActive(true)
            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            audioSession.addObserver(self,
                                     forKeyPath: "outputVolume", options: .new, context: nil)
        } catch {
            print("error occurs at obeserver adding")
        }
    }
    
    func removeVolumeChangeObserver(){
        do{
            try audioSession.setActive(false)
            audioSession.removeObserver(self, forKeyPath: "outputVolume")
        } catch {
            print("error occurs at obeserver removing")
        }
    }
    
    
    
    func setSystemOutputValue(value: Float){
        if let slide = volumeView.subviews[1] as? UISlider{
            slide.setValue(value, animated: false)
        }
    }
    
    func hideSystemVolumeHUD(){
        volumeView = MPVolumeView(frame: CGRect(x: 0, y: -100, width: 0, height: 0))
        view.addSubview(volumeView)
    }
    
 
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            
            if ( restoreVolume == true){
                // volume changed caused by setSystemOutputValue method rather by user, so ignore it
                restoreVolume = false
                return
            }
            if let currentVolume = change?[.newKey] as? Float{
                var key: VolumeKeys
                
                print("current: \(currentVolume) system: \(systemOutputVolume) ")
                key = currentVolume > systemOutputVolume ? .up : .down
                restoreVolume = true
                setSystemOutputValue(value: systemOutputVolume)
                
                volumeButtonPressed(key: key)
            }
        }
    }
    
    func volumeButtonPressed(key : VolumeKeys){
        let keyString = key == .up ? "Previous" : "Next"
        print( keyString)
        let data = keyString.data(using: String.Encoding.utf8)
        myPeripheralManager.updateValue(data!, for: arrowKeyCharacteristic, onSubscribedCentrals: nil)
    }
    
    
    // MARK: Bluetooth - Peripheral Manager
    private func setupPeripheral(){
        myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn{
            print("peripheral power on")
            cursorPositionCharacteristic = CBMutableCharacteristic(type: cursorPositionUUID, properties: [.read,.notify], value: nil, permissions: .readable)
            arrowKeyCharacteristic = CBMutableCharacteristic(type: arrowKeyUUID, properties: [.read,.notify], value: nil, permissions: .readable)
            let myService = CBMutableService(type: myServiceUUID, primary:true)
            myService.characteristics = [cursorPositionCharacteristic, arrowKeyCharacteristic]
            myPeripheralManager.add(myService)
            let advertisingData : [ String : [AnyObject]] = [
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
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error == nil {
            print("start Advertising")
        }
        else {
            print(error!)
        }
    }
    
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print(" did subscribe characteristic")
    }
    
    
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            gestureFingerNumber = sender.numberOfTouches
        case .changed:
            if gestureFingerNumber == 1{
                gestureForCursorPosition(sender: sender)
            }else{
                gestureForSettingViews(sender: sender)
            }
        case .ended:
            if gestureFingerNumber != 1 {
                rearrangeSettingViewsAfterPanGesture()
            }
        default:
            break
        }
    }
    
    func gestureForSettingViews(sender: UIPanGestureRecognizer){
        let point = sender.translation(in: view)
        sender.setTranslation(CGPoint.zero, in: view)
        moveSettingViewsXBy(x: point.x)
    }
    
    func gestureForCursorPosition(sender: UIPanGestureRecognizer){
        let point = sender.translation(in: trackpadView)
        sender.setTranslation(CGPoint.zero, in: trackpadView)
        var xOfPoint = Double(point.x) * Double(cursorSpeed)
        var yOfPoint = Double(point.y) * Double(cursorSpeed)
        let cursorData = NSMutableData()
        cursorData.append(&xOfPoint, length: MemoryLayout<Double>.size)
        cursorData.append(&yOfPoint, length: MemoryLayout<Double>.size)
        myPeripheralManager.updateValue(cursorData as Data, for: cursorPositionCharacteristic, onSubscribedCentrals: nil)
        
    }
    @IBAction func brightnessPressed() {
        switch brightnessState {
        case .off:
            brightnessState = .on
            UIScreen.main.brightness = systemBrightness
        case .on:
            brightnessState = .off
            UIScreen.main.brightness = 0
        }
    }

    @IBAction func speedChanged(_ sender: UISlider) {
        cursorSpeed = sender.value
    }
}


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
            let rotateTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            speedSlider.transform = rotateTransform
            speedSlider.setThumbImage(UIImage(named: "thumb"), forState: .Normal)
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    
    lazy var settingViews : [UIView] = {
        var views = [UIView]()
        views.append(self.speedSlider)
        views.append(self.stackView)
        return views
    }()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
            let defaults = NSUserDefaults.standardUserDefaults()
            var cursorSpeedValue = defaults.floatForKey("cursorSpeed")
            if cursorSpeedValue == 0 {
                cursorSpeedValue = 1
            }
            return cursorSpeedValue
        }
        set{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setFloat(newValue, forKey: "cursorSpeed")
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
        moveSettingViewsXBy(distence)
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
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            if leftDistence > rightDistence {
                self.moveSettingViewsXBy(rightDistence)
            }else{
                self.moveSettingViewsXBy(-leftDistence)
            }
            }, completion: nil)
    }
    
    // MART: volume button
    
    func bindApplicationLifeCycleNotifications(){
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil, usingBlock: appActive)
        center.addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil, usingBlock: appResignActive)
    }
    
    func appActive(note : NSNotification){
        addVolumeChangeObserver()
        systemBrightness = UIScreen.mainScreen().brightness
        if brightnessState == .off {
            UIScreen.mainScreen().brightness =  0
        }
    }
    
    func appResignActive(note : NSNotification){
        removeVolumeChangeObserver()
        UIScreen.mainScreen().brightness = systemBrightness
        
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
        setSystemOutputValue(systemOutputVolume)
        do{
            try audioSession.setActive(true)
            try audioSession.setCategory(AVAudioSessionCategoryAmbient)
            audioSession.addObserver(self,
                                     forKeyPath: "outputVolume", options: .New, context: nil)
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume"{
            
            if ( restoreVolume == true){
                // volume changed caused by setSystemOutputValue method rather by user, so ignore it
                restoreVolume = false
                return
            }
            if let currentVolume = change?["new"] as? Float{
                var key: VolumeKeys
                
                print("current: \(currentVolume) system: \(systemOutputVolume) ")
                key = currentVolume > systemOutputVolume ? .up : .down
                restoreVolume = true
                setSystemOutputValue(systemOutputVolume)
                
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
    
    
    @IBAction func panGestureHandler(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            gestureFingerNumber = sender.numberOfTouches()
        case .Changed:
            if gestureFingerNumber == 1{
                gestureForCursorPosition(sender)
            }else{
                gestureForSettingViews(sender)
            }
        case .Ended:
            if gestureFingerNumber != 1 {
                rearrangeSettingViewsAfterPanGesture()
            }
        default:
            break
        }
    }
    
    func gestureForSettingViews(sender: UIPanGestureRecognizer){
        let point = sender.translationInView(view)
        sender.setTranslation(CGPointZero, inView: view)
        moveSettingViewsXBy(point.x)
    }
    
    func gestureForCursorPosition(sender: UIPanGestureRecognizer){
        let point = sender.translationInView(trackpadView)
        sender.setTranslation(CGPointZero, inView: trackpadView)
        var xOfPoint = Double(point.x) * Double(cursorSpeed)
        var yOfPoint = Double(point.y) * Double(cursorSpeed)
        let cursorData = NSMutableData()
        cursorData.appendBytes(&xOfPoint, length: sizeof(Double))
        cursorData.appendBytes(&yOfPoint, length: sizeof(Double))
        myPeripheralManager.updateValue(cursorData, forCharacteristic: cursorPositionCharacteristic, onSubscribedCentrals: nil)
        
    }
    @IBAction func brightnessPressed() {
        switch brightnessState {
        case .off:
            brightnessState = .on
            UIScreen.mainScreen().brightness = systemBrightness
        case .on:
            brightnessState = .off
            UIScreen.mainScreen().brightness = 0
        }
    }
    @IBAction func speedChanged(sender: UISlider) {
        cursorSpeed = sender.value
    }
}


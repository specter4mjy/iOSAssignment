//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/8/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

enum ControlMode: Int{
    case panGesture = 1
    case attitude = 2
}

struct DefaultsKeys{
    static let rowsCount = "rowsCount"
    static let ballsCount = "ballsCount"
    static let bounciness = "bounciness"
    static let controlMode = "controlMode"
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var ballsCountSegment: UISegmentedControl!
    @IBOutlet weak var bricksRowsCountLabel: UILabel!
    @IBOutlet weak var bricksRowsStepper: UIStepper!
    @IBOutlet weak var bouncinessSlider: UISlider!
    @IBOutlet weak var controlModeSegment: UISegmentedControl!
    
    private var ballCount = 1 {
        didSet{
            ballsCountSegment.selectedSegmentIndex = ballCount - 1
        }
    }
    
    
    private var bricksRowsCount = 1 {
        didSet{
            bricksRowsCountLabel.text = bricksRowsCount.description
            bricksRowsStepper.value = Double(bricksRowsCount)
        }
    }
    
    private var bouncinessValue : Float = 0.5 {
        didSet{
            bouncinessSlider.setValue(bouncinessValue, animated: true)
        }
    }
    
    private var controlMode = ControlMode.attitude {
        didSet{
            controlModeSegment.selectedSegmentIndex = controlMode.rawValue - 1
        }
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getSettingsValuesFromUserDefault()
        setupBouncinessSlider()
        setupBrickRowsStepper()
    }
    
    private func getSettingsValuesFromUserDefault(){
        let defaultBallCount = defaults.integerForKey(DefaultsKeys.ballsCount)
        if defaultBallCount != 0 {
            ballCount = defaultBallCount
        }
        
        let defaultRowsCount = defaults.integerForKey(DefaultsKeys.rowsCount)
        if defaultRowsCount != 0 {
            bricksRowsCount = defaultRowsCount
        }
        let defaultBouncinessValue = defaults.floatForKey(DefaultsKeys.bounciness)
        if defaultBouncinessValue != 0 {
            bouncinessValue = defaultBouncinessValue
        }
        
        let defaultControlMode = defaults.integerForKey(DefaultsKeys.controlMode)
        if defaultControlMode != 0 {
            controlMode = ControlMode(rawValue: defaultControlMode)!
        }
    }
    
    private func setupBouncinessSlider(){
        bouncinessSlider.minimumValue = 0.1
        bouncinessSlider.maximumValue = 0.5
    }
    
    private func setupBrickRowsStepper(){
        bricksRowsStepper.stepValue = 1
        bricksRowsStepper.minimumValue = 1
        bricksRowsStepper.maximumValue = Double(BreakoutModel.maximumOfBrickRow)
        bricksRowsStepper.autorepeat = true
        bricksRowsStepper.wraps = true
    }
    @IBAction func changeBallsCount(sender: UISegmentedControl) {
        let count  = sender.selectedSegmentIndex + 1
        defaults.setInteger(count, forKey: DefaultsKeys.ballsCount)
    }
    @IBAction func changeBricksRowsCount(sender: UIStepper) {
        bricksRowsCount = Int(sender.value)
        defaults.setInteger(bricksRowsCount, forKey: DefaultsKeys.rowsCount)
    }
    @IBAction func changeBounciness(sender: UISlider) {
        bouncinessValue = sender.value
        defaults.setFloat(bouncinessValue, forKey: DefaultsKeys.bounciness)
    }
    @IBAction func changeControlMode(sender: UISegmentedControl) {
        let mode = sender.selectedSegmentIndex + 1
        defaults.setInteger(mode, forKey: DefaultsKeys.controlMode)
    }
}

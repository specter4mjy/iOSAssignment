//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Junyang ma on 4/8/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var ballsCountSegment: UISegmentedControl!
    @IBOutlet weak var bricksRowsCountLabel: UILabel!
    @IBOutlet weak var bricksRowsStepper: UIStepper!
    @IBOutlet weak var bouncinessSlider: UISlider!
    
    private var ballCount = 1 {
        didSet{
            ballsCountSegment.selectedSegmentIndex = ballCount
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
        
    }
    
    private func setupBouncinessSlider(){
        bouncinessSlider.minimumValue = 0.0
        bouncinessSlider.maximumValue = 1.0
    }
    
    private func setupBrickRowsStepper(){
        bricksRowsStepper.stepValue = 1
        bricksRowsStepper.minimumValue = 1
        bricksRowsStepper.maximumValue = Double(BreakoutModel.maximumOfBrickRow)
        bricksRowsStepper.autorepeat = true
        bricksRowsStepper.wraps = true
    }
    @IBAction func changeBallsCount(sender: UISegmentedControl) {
        let count  = sender.selectedSegmentIndex
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
}

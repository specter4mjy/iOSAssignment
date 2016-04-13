//
//  BreakoutModel.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class BreakoutModel {
    
    static let maximumOfBrickRow = 8
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var ballSize = CGSize(width: 22, height: 22)
    
    var paddleSize = CGSize(width: 100, height: 20)
    var paddleDistanceToBottom : CGFloat = 30
    var paddleCornerRadius : CGFloat {
        return paddleSize.height / 2
    }
    
    var numberOfBricksPerRow = 4
    var numberOfBrickRows : Int {
        var defaultRowCount =  defaults.integerForKey(DefaultsKeys.rowsCount)
        defaultRowCount = defaultRowCount == 0 ? 4 : defaultRowCount
        return defaultRowCount
    }
    var brickHeight: CGFloat = 20
    var bricksDistanceToTop : CGFloat = 30
    var gapBetweenBricks: CGFloat = 5
    var bricksCornerRadius : CGFloat = 7
    var widthRatioatioOfBricksOverContainer = 0.8
    
    
    var controlMode :ControlMode {
        var rawValue = defaults.integerForKey(DefaultsKeys.controlMode)
        rawValue = rawValue == 0 ? 1 : rawValue
        return ControlMode(rawValue: rawValue)!
    }
    
    var bounciness : Float{
        var defaultValue = defaults.floatForKey(DefaultsKeys.bounciness)
        defaultValue = defaultValue == 0.0 ? 0.5 : defaultValue
        return defaultValue
    }
    
    var numberOfTotalBricks : Int  {
        return numberOfBricksPerRow * numberOfBrickRows
    }
    
}

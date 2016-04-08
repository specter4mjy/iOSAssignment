//
//  BreakoutModel.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class BreakoutModel {
    var ballSize = CGSize(width: 30, height: 30)
    
    var paddleSize = CGSize(width: 100, height: 20)
    var paddleDistanceToBottom : CGFloat = 30
    var paddleCornerRadius : CGFloat {
        return paddleSize.height / 2
    }
    
    var numberOfBricksPerRow = 4
    var numberOfBrickRows = 7
    var brickHeight: CGFloat = 20
    var bricksDistanceToTop : CGFloat = 30
    var gapBetweenBricks: CGFloat = 5
    var bricksCornerRadius : CGFloat = 7
    var widthRatioatioOfBricksOverContainer = 0.8
    
    var numberOfTotalBricks : Int  {
        return numberOfBricksPerRow * numberOfBrickRows
    }
}

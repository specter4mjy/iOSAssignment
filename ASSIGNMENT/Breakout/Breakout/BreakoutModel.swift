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
    var paddleDistanceToBottom : CGFloat = 60
    var numberOfBricksPerRow = 5
    var numberOfBrickRows = 5
    var brickHeight: CGFloat = 20
    var bricksDistanceToTop : CGFloat = 50
    var gapBetweenBricks: CGFloat = 1
    var bricksCornerRadius : CGFloat = 7
}

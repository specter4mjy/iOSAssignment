//
//  PolygonShape.swift
//  HelloPoly
//
//  Created by Junyang ma on 3/2/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import Foundation

public class PolygonShape {
    public var numberOfSides = 3 {
        didSet {
            if let newName = PolygonNames[numberOfSides]{
                name = newName
            }
        }
    }
    public var name = "Triangle"

    private var PolygonNames : [Int : String]
    
    init (){
        PolygonNames = [Int : String]()
        PolygonNames[3]  = "Triangle"
        PolygonNames[4]  = "Square"
        PolygonNames[5]  = "Pentagon"
        PolygonNames[6]  = "Hexagon"
        PolygonNames[7]  = "Heptagon"
        PolygonNames[8]  = "Octagon"
        PolygonNames[9]  = "Nonagon"
        PolygonNames[10] = "Decagon"
        PolygonNames[11] = "Hendecagon"
        PolygonNames[12] = "Dodecagon"
    }
}
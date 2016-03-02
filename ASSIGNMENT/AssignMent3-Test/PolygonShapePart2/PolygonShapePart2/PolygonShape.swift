//
//  PolygonShape.swift
//  HelloPoly
//
//  Created by Junyang ma on 3/2/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

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
    
    var polygonPoints = { (rect: CGRect, numberOfSides: Int) -> Array<CGPoint> in
        print("get Point is called and the numberOfSides is \(numberOfSides)")
        let center = rect.center
        let radius = min(rect.size.width, rect.size.height) / 2.0
        let arc = CGFloat(2.0 * CGFloat(M_PI) / CGFloat(numberOfSides))
        
        var vertexArray : Array<CGPoint> = Array()
        for i in 0..<numberOfSides {
            var vertex = center
            vertex.x += cos(arc * CGFloat(i) - CGFloat(M_PI_2)) * radius
            vertex.y += sin(arc * CGFloat(i) - CGFloat(M_PI_2)) * radius
            vertexArray.append(vertex)
        }
        return vertexArray
    }
}

private extension CGRect {
    var center: CGPoint {
        get{
            return CGPointMake(size.width / 2.0  +  origin.x , size.height / 2.0 + origin.y)
        }
    }
}
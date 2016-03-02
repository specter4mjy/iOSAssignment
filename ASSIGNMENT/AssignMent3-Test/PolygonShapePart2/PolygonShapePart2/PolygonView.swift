//
//  PolygonView.swift
//  PolygonShapePart2
//
//  Created by Junyang ma on 3/2/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

protocol PolygonProtocol:class {
    func pointsInRect(rect: CGRect) -> Array<CGPoint>
}

class PolygonView: UIView {
    
    var dataSource : PolygonProtocol?

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        if let vertices = dataSource?.pointsInRect(bounds) where vertices.count > 0{
        path.moveToPoint(vertices[0])
        for i in 1..<vertices.count{
            path.addLineToPoint(vertices[i])
        }
        path.closePath()
        }
        UIColor.blueColor().setStroke()
        UIColor.greenColor().setFill()
        path.lineWidth = 1.5
        path.stroke()
        path.fill()
    }
    
    

}

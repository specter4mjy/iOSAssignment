//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Junyang ma on 4/4/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    private lazy var collisionBehavior : UICollisionBehavior  = {
       var collisionBehavior = UICollisionBehavior()
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        return collisionBehavior
    }()
    
    private lazy var itemBehavior : UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.elasticity = 1.0
        itemBehavior.friction = 0.0
        itemBehavior.resistance = 0.0
        itemBehavior.angularResistance = 0.0
        itemBehavior.allowsRotation = false
        return itemBehavior
    }()
    
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(viewItem: UIView) {
        dynamicAnimator?.referenceView?.addSubview(viewItem)
        collisionBehavior.addItem(viewItem)
        itemBehavior.addItem(viewItem)

    }
    
    func removeItem(viewItem: UIView){
        dynamicAnimator?.referenceView?.addSubview(viewItem)
        collisionBehavior.removeItem(viewItem)
        itemBehavior.removeItem(viewItem)
    }
    
    func addCollisionBoundaryOfViewFrame( identifier: String, viewItem: UIView){
      
        let path = UIBezierPath(rect: viewItem.frame)
        collisionBehavior.addBoundaryWithIdentifier(identifier, forPath: path)
    }
    
    func moveCollisionBoundaryOfViewFrame( identifier: String, viewItem: UIView){
        collisionBehavior.removeBoundaryWithIdentifier(identifier)
        let path = UIBezierPath(rect: viewItem.frame)
        collisionBehavior.addBoundaryWithIdentifier(identifier, forPath: path)

    }


}

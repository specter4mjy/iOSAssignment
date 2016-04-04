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
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
    }
    
    func addItem(viewItem: UIView) {
        collisionBehavior.addItem(viewItem)
    }
    
    func removeItem(viewItem: UIView){
        collisionBehavior.removeItem(viewItem)
    }
}

}

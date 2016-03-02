//
//  ViewController.swift
//  HelloPoly
//
//  Created by Junyang ma on 3/2/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy private var polygonShapeModel = PolygonShape() 

    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        setupLabels()
        controlButtonsState()
    }
    
    private func controlButtonsState(){
        decreaseButton.enabled = polygonShapeModel.numberOfSides > 3
        increaseButton.enabled = polygonShapeModel.numberOfSides < 12
    }
    
    private func setupLabels(){
            let polygonNumber = polygonShapeModel.numberOfSides
            NumberLabel.text = "Number of Sides: \(polygonNumber)"
            NameLabel.text = polygonShapeModel.name
    }

    @IBAction func decreasePress(sender: UIButton) {
        polygonShapeModel.numberOfSides -= 1
        setupLabels()
        controlButtonsState()
        print("I'm in the decrease method and numberOfSides is \(polygonShapeModel.numberOfSides)")
    }
    @IBAction func increasePrese(sender: UIButton) {
        polygonShapeModel.numberOfSides += 1
        setupLabels()
        controlButtonsState()
        print("I'm in the increase method and numberOfSides is \(polygonShapeModel.numberOfSides)")
    }
}


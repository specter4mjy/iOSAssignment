//
//  ViewController.swift
//  HelloPoly
//
//  Created by Junyang ma on 3/2/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController,PolygonProtocol {
    
    lazy private var polygonShapeModel = PolygonShape() 

    @IBOutlet weak var polygonView: PolygonView!{
        didSet{
            polygonView.dataSource = self
        }
    }
    @IBOutlet weak var NumberLabel: UILabel!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        setupLabelAndPolygonView()
        controlButtonsState()
    }
    
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.integerForKey("numberOfSides") >= 3 {
        polygonShapeModel.numberOfSides = defaults.integerForKey("numberOfSides")
        }
    }
    
    @IBAction func swipeHandler(sender: UISwipeGestureRecognizer) {
        if (sender.state ==  UIGestureRecognizerState.Ended){
            if sender.direction == UISwipeGestureRecognizerDirection.Left{
                numberOfPolygon(.decrease)
            }else if sender.direction == UISwipeGestureRecognizerDirection.Right{
                numberOfPolygon(.increase)
            }
        }
    }
    
    // implement the PolygonProtocol
    func pointsInRect(rect: CGRect) -> Array<CGPoint> {
        print("delegation is called")
        return polygonShapeModel.polygonPoints(rect,polygonShapeModel.numberOfSides)
    }
    
    private func controlButtonsState(){
        decreaseButton.enabled = polygonShapeModel.numberOfSides > 3
        increaseButton.enabled = polygonShapeModel.numberOfSides < 12
    }
    
    private func setupLabelAndPolygonView(){
            let polygonNumber = polygonShapeModel.numberOfSides
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(polygonShapeModel.numberOfSides, forKey: "numberOfSides")
            NumberLabel.text = "Number of Sides: \(polygonNumber)"
            polygonView.setNeedsDisplay()
    }
    
    private enum NumberOfPolygonChange{
        case increase
        case decrease
    }
    private func numberOfPolygon( numberOfPolygonChange:NumberOfPolygonChange){
        switch numberOfPolygonChange{
        case .increase:
            if polygonShapeModel.numberOfSides < 12{
                polygonShapeModel.numberOfSides += 1
            }
        case .decrease:
            if polygonShapeModel.numberOfSides > 3{
                polygonShapeModel.numberOfSides -= 1
            }
        }
        setupLabelAndPolygonView()
        controlButtonsState()
    }

    @IBAction func decreasePress(sender: UIButton) {
        numberOfPolygon(.decrease)
        print("I'm in the decrease method and numberOfSides is \(polygonShapeModel.numberOfSides)")
    }
    @IBAction func increasePrese(sender: UIButton) {
        numberOfPolygon(.increase)
        print("I'm in the increase method and numberOfSides is \(polygonShapeModel.numberOfSides)")
    }
    @IBAction func stepperPress(sender: UIStepper) {
        polygonShapeModel.numberOfSides = Int(sender.value)
        setupLabelAndPolygonView()
        controlButtonsState()
    }
}


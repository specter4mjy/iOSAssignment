//
//  ViewController.swift
//  TipCalc
//
//  Created by Junyang ma on 2/13/16.
//  Copyright © 2016 Junyang ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var billAmountLabel: UILabel!
    @IBOutlet weak var customTipPercentLabel1: UILabel!
    @IBOutlet weak var customTipPercentLabel2: UILabel!
    @IBOutlet weak var customTipPercentageSlider: UISlider!
    @IBOutlet weak var tip15Label: UILabel!
    @IBOutlet weak var tipCustomLabel: UILabel!
    @IBOutlet weak var total15Label: UILabel!
    @IBOutlet weak var totalCustomLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!

    let decimal100 = NSDecimalNumber(string: "100.0")
    let decimal15Percent = NSDecimalNumber(string: "0.15")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.becomeFirstResponder()
    }
    
    @IBAction func calculateTip(sender: AnyObject) {
        let sliderValue = NSDecimalNumber(integer: Int(customTipPercentageSlider.value))
        let customPercent = sliderValue / decimal100
        
        if sender is UISlider
        {
            customTipPercentLabel1.text = customPercent.formatAsPercent()
            customTipPercentLabel2.text = customTipPercentLabel1.text
        }
        
        if let inputString = inputTextField.text where !inputString.isEmpty{
            let billAmount = NSDecimalNumber(string: inputString) / decimal100
            if sender is UITextField{
                billAmountLabel.text = " " + billAmount.formatAsCurrency()
                let fifteenTip = billAmount * decimal15Percent
                tip15Label.text = fifteenTip.formatAsCurrency()
                total15Label.text = (billAmount + fifteenTip).formatAsCurrency()
            }
            
            let customTip = billAmount * customPercent
            tipCustomLabel.text = customTip.formatAsCurrency()
            totalCustomLabel.text = (billAmount + customTip).formatAsCurrency()
        }
        else{
            billAmountLabel.text=" "
            tip15Label.text=" "
            total15Label.text=" "
            tipCustomLabel.text=" "
            totalCustomLabel.text=" "
        }
        
        
    }
    

}


extension NSNumber {
    func formatAsCurrency() -> String {
        return NSNumberFormatter.localizedStringFromNumber(self,
            numberStyle: NSNumberFormatterStyle.CurrencyStyle)
    }
    
    func formatAsPercent() -> String {
        return NSNumberFormatter.localizedStringFromNumber(self,
            numberStyle: NSNumberFormatterStyle.PercentStyle)
    }
}

func + (left:NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
    return left.decimalNumberByAdding(right)
}
func * (left:NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
    return left.decimalNumberByMultiplyingBy(right)
}
func / (left:NSDecimalNumber, right: NSDecimalNumber) -> NSDecimalNumber {
    return left.decimalNumberByDividingBy(right)
}


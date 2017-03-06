//
//  ViewController.swift
//  Calculator
//
//  Created by linh on 2/22/17.
//  Copyright © 2017 Blue Fronted. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()

    private var displayValue: Double{
        get {
            //this remove white space that was appended when the input label is empty
            return Double(display.text!.trimmingCharacters(in: .whitespaces))!
        }
        set {
            display.text = String(newValue)
            
        }
    }

    
    @IBAction func clearCalculator(_ sender: UIButton) {
        brain = CalculatorBrain ()
        userIsInTheMiddleOfTyping = false
        display.text = " "
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        //if display.text?.characters.count != 0,
        if let lastIndex = display.text?.index(before: (display.text?.endIndex)!) {
            NSLog("last is \(lastIndex)")
            display.text?.remove(at: lastIndex)
            if display.text?.characters.count == 0 {
                display.text = " "
            }
        }
        //}
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!

        if (display.text?.characters.contains("."))! && digit == "." {
            //do nothing---> this can be flipped usign demorgan's law
            // there is a little bug, 
            // on the second operand can't start out with a dot.
            // it has to start with a 0. to clear the screen.
        } else {
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
        }
        
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}


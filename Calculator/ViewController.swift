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
            let formattedValue = NumberFormatter ()
            let number = NSNumber(value: newValue)
            formattedValue.maximumFractionDigits = 6
            display.text = formattedValue.string(from: number)
        }
    }
    
    
    @IBAction func clearCalculator(_ sender: UIButton) {
        brain = CalculatorBrain ()
        userIsInTheMiddleOfTyping = false
        display.text = " "
        status.text = " "
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
    
    @IBOutlet weak var labelMemory: UILabel!
    
    //from ->M
    @IBAction func setMemoryM(_ sender: UIButton) {
    //label
        labelMemory.text = String(displayValue)
//        brain.evaluate()
        
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
    
    
    //from M
    @IBAction func getMemoryM(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            //calling this again caused the dublication in M
            
        }
        
//        if brain.description == nil {
//            status.text = " "
//        } else {
//
//            status.text = brain.description! + ( brain.resultIsPending ? ("...") : (" ="))
//        }
//        
//        if let result = brain.result {
//            displayValue = result
//        }
//        
    }
    

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
        }
        

        if brain.description == nil {
            status.text = " "
        } else {
            
            if brain.resultIsPending {
                status.text = brain.description! + ("...")
            } else {
                status.text = brain.description! + (" =")
                
            }
        }
        
        if let result = brain.result {
            displayValue = result
        }
    }
}


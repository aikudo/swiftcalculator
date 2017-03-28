//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by linh on 2/22/17.
//  Copyright © 2017 Blue Fronted. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var myDict = [String: Double] ()
    
    private var brain = CalculatorBrain()
    
    private var displayValue: Double{
        get {
            //this remove white space that was appended when the input label is empty
            return Double(display.text!.trimmingCharacters(in: .whitespaces)) ?? 0.0
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
        myDict = [String: Double] ()
        userIsInTheMiddleOfTyping = false
        display.text = " "
        status.text = " "
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        if(userIsInTheMiddleOfTyping) {
            if let lastIndex = display.text?.index(before: (display.text?.endIndex)!) {
                NSLog("last is \(lastIndex)")
                display.text?.remove(at: lastIndex)
                if display.text?.characters.count == 0 {
                    display.text = " "
                }
            }
        } else {
            brain.undo() //need to update the screen?
        }
    }
    
    @IBOutlet weak var labelMemory: UILabel!
    
    
    
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
    
    //from ->M
    @IBAction func setMemoryM(_ sender: UIButton) {
        labelMemory.text = String(displayValue)
        myDict["M"] = displayValue
        let (result, isPending, description) = brain.evaluate(using: myDict)
        
        status.text = description + (isPending  ? ("...") : (" ="))
        
        if let result = result {
            displayValue = result
        }
        
        
    }
    
    //from M
    @IBAction func getMemoryM(_ sender: UIButton) {
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.setOperand(variable: mathematicalSymbol)
            let result = brain.evaluate().result
            displayValue = result ?? displayValue
            // note that we don't update the description because of 7.c
            
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
    
    

    
    private func compute(_ inputX: Double ) -> Double? {
        myDict["M"] = inputX
        return brain.evaluate(using: myDict).result
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dvc = segue.destination as? GraphViewController {
            dvc.title = brain.description
            dvc.function = compute
            
        }
    }
    
}


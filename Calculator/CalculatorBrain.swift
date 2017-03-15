//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by linh on 2/26/17.
//  Copyright © 2017 Blue Fronted. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    
    private var accumulator: Double?
    
    private enum Operation {
        //here we attach an associated value type which is Double
        case constant(Double)
        case randomOperation
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "RND" : Operation.randomOperation,
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "log" : Operation.unaryOperation(log),
        "exp" : Operation.unaryOperation(exp),
        "x²" : Operation.unaryOperation( {$0*$0} ),
        "1/x" : Operation.unaryOperation( {1/$0} ),
        "±": Operation.unaryOperation( {-$0} ),
        "+": Operation.binaryOperation( {$0 + $1} ),
        "−": Operation.binaryOperation( {$0 - $1} ),
        "×": Operation.binaryOperation( {$0 * $1} ),
        "÷": Operation.binaryOperation( {$0 / $1} ),
        "=": Operation.equals
        
    ]
    
    var description: String?
    
    var accumulatorString: String?
    
    var dontPrepend: Bool? // quick hack to filter out extra leading accumulator
    
    // failed f. g. and i.
    mutating func performOperation(_ symbol: String) {
        var performedString: String?
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                accumulatorString = symbol
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    
                    if accumulatorString != nil{
                        if symbol == "x²" {
                            performedString = "(\(accumulatorString!))²"
                        } else {
                            performedString = symbol + "(\(accumulatorString!))"
                        }
                    } else {
                        if symbol == "x²" {
                            description = "(\(description!))²"
                        } else {
                            description = symbol + "(\(description!))"
                        }
                    }
                    
                    accumulator = function(accumulator!)
                    accumulatorString = nil
                    dontPrepend = true
                }
                
            case .randomOperation:
                accumulator = Double(arc4random()) / Double(UInt32.max)
                accumulatorString = "RND"
                
            case .binaryOperation(let fn):
                
                if accumulator != nil { //multiple times operating on the operator will be skimmed
                    if dontPrepend != nil {
                        performedString = " \(symbol) "
                        dontPrepend = nil
                        
                    } else {
                        performedString = accumulatorString! + " \(symbol) "
                        
                    }
                    
                    if pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(function: fn, firstOperand: accumulator!)
                    resultIsPending = true
                    accumulator = nil //accumulator is moved into the pbo
                    accumulatorString = nil
                }
                
                //this failed case i. because it doesn't autoclean up
            case .equals:
                if accumulator != nil && pendingBinaryOperation != nil {
                    performedString = accumulatorString ?? ""
                    performPendingBinaryOperation()
                    accumulatorString = nil
                    dontPrepend = true
                }
                
            }
            
        }
        
        if performedString != nil {
            if description == nil {
                description = performedString
            } else {
                description = description! + performedString!
            }
        }
        
    }
    //    var accumulatorString: String
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            accumulatorString = String(accumulator!)
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }
    
    //this stores a function and a first operand
    //it can also perform a function
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        
        let number = NSNumber(value: operand)
        let formatNumber = NumberFormatter()
        if let operandFormatted = formatNumber.string(from: number) {
            accumulatorString = operandFormatted
        }
        
        
    }
    
    var resultIsPending: Bool = false
    
    var result: Double? {
        get {
            return accumulator
            
        }
    }
}

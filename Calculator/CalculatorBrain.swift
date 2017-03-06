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
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±": Operation.unaryOperation( {-$0} ),
        "+": Operation.binaryOperation( {$0 * $1} ),
        "−": Operation.binaryOperation( {$0 - $1} ),
        "×": Operation.binaryOperation( {$0 * $1} ),
        "÷": Operation.binaryOperation( {$0 / $1} ),
        "=": Operation.equals

    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil //accumulator is moved into the pbo
                }
            case .equals: performPendingBinaryOperation()
                
            }
            
        }
        
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil{
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            pendingBinaryOperation = nil
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
        
    }
    
    var result: Double? {
        get {
            return accumulator
            
        }
    }
}

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
        case constant(Double, String)
        case randomOperation
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private enum Instruction {
        case operation(String)
        case operand(Double)
        case operandMemonic(String)
    }
    
    private var instructionList = [Instruction]()
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "RND" : Operation.randomOperation,
        "√" : Operation.unaryOperation(sqrt, { "√(\($0))" } ),
        "sin" : Operation.unaryOperation(sin, { "sin(\($0))" } ),
        "cos" : Operation.unaryOperation(cos, { "cos(\($0))" } ),
        "tan" : Operation.unaryOperation(tan, { "tan(\($0))" } ),
        "log" : Operation.unaryOperation(log, { "log(\($0))" } ),
        "exp" : Operation.unaryOperation(exp, { "exp(\($0))" } ),
        "x²" : Operation.unaryOperation( {$0*$0}, { "(\($0))²" } ),
        "1/x" : Operation.unaryOperation( {1/$0},  { "1/(\($0))" } ),
        "±": Operation.unaryOperation( {-$0}, { "-(\($0))" } ),
        "+": Operation.binaryOperation( {$0 + $1}, { "\($0) + \($1)"} ),
        "−": Operation.binaryOperation( {$0 - $1}, { "\($0) - \($1)"} ),
        "×": Operation.binaryOperation( {$0 * $1}, { "\($0) × \($1)"} ),
        "÷": Operation.binaryOperation( {$0 / $1}, { "\($0) ÷ \($1)"} ),
        "=": Operation.equals
        
    ]
    
    var result: Double? {
        get{
            return evaluate().result
        }
    }
    
    var description: String? {
        get {
            return evaluate().description
        }
    }
    
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
    

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let functionDescription: (String, String) -> String
        let firstOperand: Double
        let firstOperandDescription: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperandDescription: String) -> String {
            return functionDescription(firstOperandDescription, secondOperandDescription)
        }
    }
    
    
    mutating func performOperation(_ symbol: String) {
        let instruction  = Instruction.operation(symbol)
        instructionList.append(instruction)
    }
    
    
    mutating func setOperand(variable named: String) {
        let instruction  = Instruction.operandMemonic(named)
        instructionList.append(instruction)
    }
    
    mutating func setOperand(_ operand: Double) {
        let instruction = Instruction.operand(operand)
        instructionList.append(instruction)
    }
    
    mutating func undo() {
        if instructionList.count > 0 {
            instructionList.removeLast()
        }
    }
    
    func evaluate(using variable: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        //this is my own local variable, so it's okay. "mutating" applies to the properties variable.
        var accumulator: Double?
        var accumulatorString: String?
        
        var description: String?
        var pendingBinaryOperation: PendingBinaryOperation?
        var isPending: Bool = false
        
        
        //    var accumulatorString: String
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                accumulatorString = pendingBinaryOperation?.performDescription(with: accumulatorString!)
                pendingBinaryOperation = nil
            }
        }
        
        func performOperation(_ symbol: String) {

            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value, let valueSymbol):
                    accumulator = value
                    accumulatorString = valueSymbol
                    
                case .unaryOperation(let function, let descriptionFunction):
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                        accumulatorString = descriptionFunction(accumulatorString!)
                        description = accumulatorString

                    }
                    
                case .randomOperation:
                    accumulator = Double(arc4random()) / Double(UInt32.max)
                    accumulatorString = "RND"
                    
                case .binaryOperation(let fn, let descriptionFunction):
                    
                    if accumulator != nil { //multiple times operating on the operator will be skimmed
                        if pendingBinaryOperation != nil {
                            performPendingBinaryOperation()
                            isPending = false
                        }
                        
                        pendingBinaryOperation = PendingBinaryOperation(function: fn,
                                                                        functionDescription: descriptionFunction,
                                                                        firstOperand: accumulator!,
                                                                        firstOperandDescription: accumulatorString!
                        )
                        description = accumulatorString! + " \(symbol) "
                        isPending = true
                        
                    }
                    
                case .equals:
                    if accumulator != nil && pendingBinaryOperation != nil {
                        performPendingBinaryOperation()
                        isPending = false
                        description = accumulatorString
                        
                        for ins in instructionList {
                            NSLog ("\(ins)")
                        }
                        
                    }
                    
                }
                
            }
        }
        
        
        for instruction in instructionList {
            switch instruction {
            case .operation(let operationSymbol):
                performOperation(operationSymbol)
                
            case .operandMemonic(let operandSymbol):
                
                accumulator = variable?[operandSymbol] ?? 0.0
                accumulatorString = operandSymbol
                
            case .operand(let operandValue):
                accumulator = operandValue
                accumulatorString = NumberFormatter().string(from: NSNumber(value: operandValue))
                
            }
        }
        NSLog("performed: \(description), ans: \(accumulator)")
        
        description = description ?? accumulatorString

        return (accumulator, isPending, description!)
    }
    
    
}

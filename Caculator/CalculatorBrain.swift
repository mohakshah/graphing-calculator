//
//  CalculatorBrain.swift
//  Caculator
//
//  Created by Mohak Shah on 05/07/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π"     : Operation.Constant(M_PI),
        "e"     : Operation.Constant(M_E),
        
        "sin"   : Operation.UnaryOperation(sin),
        "log"   : Operation.UnaryOperation(log10),
        "√"     : Operation.UnaryOperation(sqrt),
        "±"     : Operation.UnaryOperation { -$0 },
        
        "+"     : Operation.BinaryOperation {$0 + $1},
        "−"     : Operation.BinaryOperation {$0 - $1},
        "×"     : Operation.BinaryOperation {$0 * $1},
        "÷"     : Operation.BinaryOperation {$0 / $1},
        
        "?"     : Operation.Random { Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)},
        
        "="     : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Random(() -> Double)
        case Equals
    }
    
    func setOperand(variableName: String) {
        if let value = variableValues[variableName] {
            accumulator = value
        } else {
            accumulator = 0.0
        }
        
        internalProgram.append(variableName)
    }
    
    var variableValues = [String: Double]()
    
    func setVariableValue(variableName: String, value: Double) {
        variableValues[variableName] = value
        print(variableValues)
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case Operation.Constant(let value):
                accumulator = value
                
            case Operation.UnaryOperation(let function):
                accumulator = function(accumulator)
                
            case Operation.BinaryOperation(let function):
                executePendingBinaryOperation()
                pendingBinaryOperation = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator)
                
            case Operation.Random(let function):
                accumulator = function()
                
            case Operation.Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperationInfo? = nil
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private func executePendingBinaryOperation() {
        if let pending = pendingBinaryOperation {
            accumulator = pending.binaryOperation(pending.firstOperand, accumulator)
            pendingBinaryOperation = nil
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pendingBinaryOperation == nil ? false : true
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let symbol = op as? String {
                        if let _ = operations[symbol] {
                            performOperation(symbol)
                        } else {
                            setOperand(symbol)
                        }
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pendingBinaryOperation = nil
        internalProgram.removeAll()
    }
    
    func undo() {
        if let arrayOfOps = program as? [AnyObject] {
            program = Array(arrayOfOps.dropLast(1))
        }
    }
    
    var description: String {
        var _description = [String]()
        
        var newEquation = false
        var needOperand = false
        
        for op in internalProgram {
            if let operand = op as? Double {
                // drop the old equation
                if newEquation {
                    _description.removeAll()
                }
                
                _description.append("\(PrettyDoubles.prettyStringFrom(double: operand))")
                
                needOperand = false
                newEquation = false
            } else if let symbol = op as? String {
                if let operation = operations[symbol] {
                    switch operation {
                    case .UnaryOperation(_):
                        let openBracketIndex: Int
                        let closeBracketIndex: Int
                        if newEquation {
                            openBracketIndex = 0
                            closeBracketIndex = _description.count + 1
                        } else {
                            openBracketIndex = _description.count - 1
                            closeBracketIndex = _description.count + 1
                        }
                        
                        _description.insert("\(symbol)(", atIndex: openBracketIndex)
                        _description.insert(")", atIndex: closeBracketIndex)
                        
                    case .BinaryOperation(_):
                        _description.append(" \(symbol) ")
                        newEquation = false
                        needOperand = true
                        
                    case .Equals:
                        if needOperand {
                            if let lastOperator = _description.popLast() {
                                // add brackets around the equation if there are more than 1 operands
                                if (_description.count > 1) {
                                    _description.insert("(", atIndex: 0)
                                    _description.append(")")
                                }
                                _description.appendContentsOf([lastOperator] + _description)
                            }
                        }
                        
                        newEquation = true
                        
                    case .Constant(_): fallthrough
                    case .Random(_):
                        if newEquation {
                            _description.removeAll()
                        }
                        
                        _description.append("\(symbol)")
                        
                        needOperand = false
                        newEquation = false
                    }
                } else {
                    // assume that the symbol is a variable
                    if newEquation {
                        _description.removeAll()
                    }
                    
                    _description.append("\(symbol)")
                    
                    needOperand = false
                    newEquation = false
                }
            }
            
        }
        
        // return the array as a single string
        return _description.joinWithSeparator("")
    }
    
    var result: Double {
        // simple way to re-evaluate the program
        // by calling the setter of the program var
        let foo = program
        program = foo
        
        return accumulator
    }
    
    
}
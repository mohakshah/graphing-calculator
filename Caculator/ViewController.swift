//
//  ViewController.swift
//  Caculator
//
//  Created by Mohak Shah on 04/07/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var secondaryDisplay: UILabel!
   
    let secondaryDisplayDefaultValue = "⏳ "
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(sender: UIButton) {
        if sender.currentTitle == "." {
            // allow only 1 decimal point
            if display.text!.containsString(".") {
                return
            } else if display.text == "0" {
                display.text = "0."
                userIsInTheMiddleOfTyping = true
                return
            }
        }
        
        if userIsInTheMiddleOfTyping {
            display.text?.appendContentsOf(sender.currentTitle!)
        } else {
            display.text = sender.currentTitle
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double? {
        get {
            if let dt = display?.text {
                return Double(dt)
            } else {
                return nil
            }
        }
        
        set {
            if let nv = newValue {
                display!.text = PrettyDoubles.prettyStringFrom(double: nv)
            } else {
                display.text = "0"
            }
        }
    }
    
    var brain = CalculatorBrain()


    @IBAction func performOperation(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            if let dv = displayValue {
                brain.setOperand(dv)
            }
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        
        updateDisplays()
    }
    
    private func updateDisplays() {
        displayValue = brain.result
        
        // set the secondary display
        secondaryDisplay.text = secondaryDisplayDefaultValue + brain.description
        
        if brain.isPartialResult {
            secondaryDisplay.text! += " ..."
        } else {
            secondaryDisplay.text! += " ="
        }
        
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func saveToMemory() {
        // only set if the display has a valid number
        if let dv = displayValue {
            brain.variableValues["M"] = dv
        }
        
        updateDisplays()
    }
    
    @IBAction func loadFromMemory() {
        brain.setOperand("M")
        
        updateDisplays()
    }
    
    @IBAction func clearAll() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        brain.variableValues.removeAll()
        displayValue = nil
        secondaryDisplay.text = secondaryDisplayDefaultValue
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTyping {
            if let dt = display.text {
                let characters = dt.characters
                
                if characters.count == 1 {
                    display.text = "0"
                    userIsInTheMiddleOfTyping = false
                    return
                }
                
                display.text = String(characters.dropLast())
            }
        } else {
            brain.undo()
            updateDisplays()
        }
    }
    
}


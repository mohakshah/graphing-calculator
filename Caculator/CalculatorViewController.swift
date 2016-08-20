//
//  ViewController.swift
//  Caculator
//
//  Created by Mohak Shah on 04/07/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    override func viewDidLoad() {
        
        showGraph.enabledBackgroundColor = UIColor(red: 1, green: 0, blue: 0.5, alpha: 1)
        showGraph.disabledBackgroundColor = UIColor.lightGrayColor()
        
        if let program = defaults.objectForKey(defaultsProgramKey) {
            brain.program = program
            updateDisplays()
        }
    }
    
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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let defaultsProgramKey = "calculatorVCProgram"


    @IBAction func performOperation(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            if let dv = displayValue {
                brain.setOperand(dv)
            }
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        defaults.setObject(brain.program, forKey: defaultsProgramKey)
        
        updateDisplays()
    }
    
    
    @IBOutlet weak var showGraph: GraphButton!
    private func updateDisplays() {
        displayValue = brain.result
        
        // set the secondary display
        secondaryDisplay.text = secondaryDisplayDefaultValue + brain.description
        
        if brain.isPartialResult {
            secondaryDisplay.text! += " ..."
            showGraph.enabled = false
        } else {
            secondaryDisplay.text! += " ="
            showGraph.enabled = true
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
        defaults.setObject(brain.program, forKey: defaultsProgramKey)
        
        updateDisplays()
    }
    
    @IBAction func clearAll() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        defaults.removeObjectForKey(defaultsProgramKey)
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
            defaults.setObject(brain.program, forKey: defaultsProgramKey)
            updateDisplays()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "showGraph"?:
            var destinationVC = segue.destinationViewController
            if let navVC = destinationVC as? UINavigationController {
                destinationVC = navVC.visibleViewController ?? destinationVC
            }
            
            if let graphVC = destinationVC as? GraphViewController {
                graphVC.brain = CalculatorBrain()
                graphVC.brain.program = brain.program
            }
            
        default:
            break;
        }
        
    }
    
}

class GraphButton: UIButton {
    override var enabled: Bool {
        didSet {
            super.enabled = enabled
            if enabled {
                if let color = enabledBackgroundColor {
                    backgroundColor = color
                }
            } else {
                if let color = disabledBackgroundColor {
                    backgroundColor = color
                }
            }
        }
    }
    
    var enabledBackgroundColor: UIColor?
    var disabledBackgroundColor: UIColor?
}
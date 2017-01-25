//
//  GraphViewController.swift
//  Caculator
//
//  Created by Mohak Shah on 17/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphDataSource
{
    var brain: CalculatorBrain! = nil
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct defaultsKeys {
        static let program = "graphVCLastProgram"
        static let graphCenterX = "graphVCCenterX"
        static let graphCenterY = "graphVCCenterY"
        static let graphScale = "graphVCScale"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.graphDS = self
        graphView.graphCentre = CGPoint(x: graphView.bounds.maxX / 2, y: graphView.bounds.maxY / 2)
        
        // the app just started
        if brain == nil {
            brain = CalculatorBrain()
            restoreProgram()
            restoreGraphScale()
            restoreGraphCenter()
        } else {
            saveProgram()
            saveGraphCenter()
            saveGraphScale()
        }
        
        navigationItem.title = brain.description
    }
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBAction func changeZoom(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Changed, .Ended:
            graphView.scale *= sender.scale
            sender.scale = 1.0
            saveGraphScale()
            
        default:
            break
        }
    }
    
    @IBAction func panRecognizer(sender: UIPanGestureRecognizer) {
        let delta = sender.translationInView(graphView)
        graphView.graphCentre.x += delta.x
        graphView.graphCentre.y += delta.y
        
        
        saveGraphCenter()
        
        sender.setTranslation(CGPointZero, inView: graphView)
    }
    
    @IBAction func shiftCentre(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            graphView.graphCentre = sender.locationInView(graphView)
            
            saveGraphCenter()
        }
    }
    
    func valueOfYFor(x: Double) -> Double {
        brain.variableValues["M"] = x;
        return brain.result
    }
    
    var shouldDraw: Bool {
        return brain.isPartialResult ? false : true
    }
    
    func saveProgram() {
        if brain == nil {
            return
        }
        
        defaults.setObject(brain.program, forKey: defaultsKeys.program)
    }
    
    func restoreProgram() {
        if brain == nil {
            return
        }
        
        if let program = defaults.objectForKey(defaultsKeys.program) {
            brain.program = program
        }
    }
    
    func saveGraphCenter() {
        if graphView.graphCentre == nil {
            return
        }
        defaults.setObject(Double(graphView.graphCentre.x), forKey: defaultsKeys.graphCenterX)
        defaults.setObject(Double(graphView.graphCentre.y), forKey: defaultsKeys.graphCenterY)
    }
    
    func restoreGraphCenter() {
        if let centerX = defaults.objectForKey(defaultsKeys.graphCenterX) as? Double {
            if let centerY = defaults.objectForKey(defaultsKeys.graphCenterY) as? Double {
                graphView.graphCentre = CGPoint(x: CGFloat(centerX), y: CGFloat(centerY))
            }
        }
    }
    
    func saveGraphScale() {
        defaults.setDouble(Double(graphView.scale), forKey: defaultsKeys.graphScale)
    }
    
    func restoreGraphScale() {
        let scale = defaults.doubleForKey(defaultsKeys.graphScale)
        if scale != 0 {
            graphView.scale = CGFloat(scale)
        }
    }
}
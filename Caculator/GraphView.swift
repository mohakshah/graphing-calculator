//
//  GraphView.swift
//  Caculator
//
//  Created by Mohak Shah on 17/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

protocol GraphDataSource: class {
    func valueOfYFor(x: Double) -> Double
    var shouldDraw: Bool { get }
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var graphCentre: CGPoint! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        set (newFrame) {
            if (graphCentre == nil) {
                super.frame = newFrame
                return
            }
            
            let yDelta = (bounds.maxY / 2) - graphCentre.y
            let xDelta = (bounds.maxX / 2) - graphCentre.x
            super.frame = newFrame
            graphCentre = CGPoint(x: (bounds.maxX / 2) - xDelta, y: (bounds.maxY / 2) - yDelta)
        }
        
        get {
            return super.frame
        }
    }
    
    weak var graphDS: GraphDataSource! = nil

    
    override func drawRect(rect: CGRect) {
        // draw the axes
        if (graphCentre == nil) {
            graphCentre = CGPoint(x: bounds.maxX / 2, y: bounds.maxY / 2)
        }
        
        AxesDrawer().drawAxesInRect(bounds, origin: graphCentre, pointsPerUnit: scale)
        
        plotGraph(bounds)
        
    }
    
    private func plotGraph(bounds: CGRect) {
        if graphDS == nil || !graphDS.shouldDraw {
            print("Not gonna draw")
            return
        }
        
        // plot the graph
        let graphMax = CGPoint(x: bounds.maxX - graphCentre.x, y: graphCentre.y - bounds.minY)
        let graphMin = CGPoint(x: bounds.minX - graphCentre.x, y: graphCentre.y - bounds.maxY)
        
        let path = UIBezierPath()
        var pathWasDiscontinuous = true
        
        var x = graphMin.x
        while (x < graphMax.x) {
            let y = CGFloat(graphDS.valueOfYFor(Double(x / scale))) * scale
            
            if (y.isZero || y.isNormal) && y < graphMax.y && y > graphMin.y {
                let nextPoint = CGPoint(x: graphCentre.x + x, y: graphCentre.y - y)
                
                if pathWasDiscontinuous {
                    path.moveToPoint(nextPoint)
                    pathWasDiscontinuous = false
                } else {
                    path.addLineToPoint(nextPoint)
                }
            } else {
                if !pathWasDiscontinuous {
                    path.stroke()
                    pathWasDiscontinuous = true
                }
            }
            
            x += (1 / contentScaleFactor)
        }
        
        path.stroke()
    }
}

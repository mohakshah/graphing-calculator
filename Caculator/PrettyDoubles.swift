//
//  PrettyDoubles.swift
//  Caculator
//
//  Created by Mohak Shah on 05/07/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation

class PrettyDoubles {
    static func prettyStringFrom(double d: Double) -> String {
        let numberFormatter = NSNumberFormatter()
        
        // set required properties on the formatter
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        
        let formattedString = numberFormatter.stringFromNumber(NSNumber(double: d))
        
        // send the formatted string, or a "0" if the formatting somehow failed
        if let s = formattedString {
            return s
        } else {
            return "0"
        }
    }
}
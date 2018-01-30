//
//  File.swift
//  PowerRanger
//
//  Created by Donna Samuel on 27/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    
    convenience init?(hex: String){
        
        // Normalizing Hex Values with #
        _ =  hex.replacingOccurrences(of: "#", with: "")
        
        // Creating Scanner to scan string for hexadecimal values
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt32 = 0
        scanner.scanHexInt32(&rgbValue)
        
        // Retrieve R, G, B CGFloat values
        let r = CGFloat(( rgbValue & 0xFF0000) >> 16 ) / 255.0
        let g = CGFloat(( rgbValue & 0x00FF00) >> 8 ) / 255.0
        let b = CGFloat( rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}

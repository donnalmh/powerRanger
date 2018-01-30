//
//  PowerRect.swift
//  PowerRanger
//
//  Created by Donna Samuel on 29/1/18.
//  Copyright © 2018 donnali. All rights reserved.
//

import UIKit

class PowerRect: UIView {
    
    var powerRanger: PowerRanger!
    var gestureRecognizer: UIPanGestureRecognizer!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        print("drawing")
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, powerRanger: PowerRanger){
        self.init(frame: frame)
        self.powerRanger = powerRanger
        self.backgroundColor = UIColor(hex: powerRanger.colourAsHex!)
        powerRanger.pointX = frame.minX
        powerRanger.pointY = frame.minY
        
    }
}

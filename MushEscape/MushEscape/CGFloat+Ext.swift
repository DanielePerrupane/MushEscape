//
//  CGFloat+Ext.swift
//  MushEscape
//
//  Created by Raffaele Marino  on 08/12/23.
//

import CoreGraphics

public let π = CGFloat.pi

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

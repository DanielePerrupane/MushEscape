//
//  Types.swift
//  MushEscape
//
//  Created by Raffaele Marino  on 12/12/23.
//

import Foundation

struct PhysicsCategory {
    static let Player:          UInt32 = 0b1
    static let Obstacles:       UInt32 = 0b10
    static let Ground:          UInt32 = 0b100
    static let Gems:            UInt32 = 0b1000
    static let Border:          UInt32 = 0b10000
}

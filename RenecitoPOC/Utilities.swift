//
//  Utilities.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/25/25.
//

import MIDIKitIO

/// Allow use with `@AppStorage` by conforming to a supported `RawRepresentable` type.
extension MIDIIdentifier: @retroactive RawRepresentable {
    public typealias RawValue = Int
    
    public init?(rawValue: RawValue) {
        self = Self(rawValue)
    }
    
    public var rawValue: RawValue {
        Int(self)
    }
}

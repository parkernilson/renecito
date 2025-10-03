//
//  Quantizer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 10/2/25.
//

import Foundation
import MIDIKitIO


enum Quantizer {
    case none
    case semitones
    
    static let allSemitones: [Double] = extendSemitoneRange([0.0, 1.0/12.0, 2.0/12.0, 3.0/12.0, 4.0/12.0, 5.0/12.0, 6.0/12.0, 7.0/12.0, 8.0/12.0, 9.0/12.0, 10.0/12.0, 11.0/12.0])
    
    static func extendSemitoneRange(_ oneOctaveSemitones: [Double], toOctaveRange octaveRange: Int = 8) -> [Double] {
        var newSemitones: [Double] = oneOctaveSemitones
        for i in 1...octaveRange {
            newSemitones.append(contentsOf: oneOctaveSemitones.map { $0 + Double(i) })
        }
        return newSemitones
    }
    
    func convertToNoteNum(voltsPerOct: Double) -> UInt7 {
        return UInt7(voltsPerOct * 12)
    }
    
    func getQuantizedNote(_ voltsPerOct: Double) -> UInt7 {
        switch self {
        case .none:
            return 0
        case .semitones:
            return convertToNoteNum(voltsPerOct: quantize(semitones: Quantizer.allSemitones, val: voltsPerOct))
        }
    }
    
    func quantize(semitones: [Double], val: Double) -> Double {
        if semitones.isEmpty {
            print("Warning: Quantizer was given an empty array of semitones, returning 0.0")
            return 0.0
        } else if semitones.count == 1 {
            return semitones[0]
        }
        
        let i = semitones.bisectLeft(val)
        
        if i == 0 {
            return semitones[i]
        } else if i == semitones.count {
            return semitones[i - 1]
        }
        
        let d1 = abs(semitones[i-1] - val)
        let d2 = abs(semitones[i] - val)
        return semitones[d1 > d2 ? i : i - 1]
    }

}

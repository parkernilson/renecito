//
//  Quantizer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 10/2/25.
//

import Foundation

/// Represents a quantizer for pitch values in the V/Oct standard (0.0-8.0V)
struct Quantizer {
    /// The semitone offsets within an octave (0-11) that are allowed
    let allowedSemitones: [Int]

    /// Quantizes a voltage value to the nearest allowed pitch
    /// - Parameter value: Input voltage (0.0-8.0V in V/Oct standard)
    /// - Returns: Quantized voltage value
    func quantize(_ value: Double) -> Double {
        // Clamp value to valid range
        let clampedValue = max(0.0, min(8.0, value))

        // If no quantization (all semitones allowed), return original value
        if allowedSemitones.count == 12 {
            return clampedValue
        }

        // Convert voltage to total semitones from 0V
        let totalSemitones = clampedValue * 12.0

        // Get the octave and semitone within octave
        let octave = floor(totalSemitones / 12.0)
        let semitoneInOctave = totalSemitones.truncatingRemainder(dividingBy: 12.0)

        // Find the nearest allowed semitone
        let nearestAllowedSemitone = findNearestAllowedSemitone(semitoneInOctave)

        // Convert back to voltage
        let quantizedSemitones = octave * 12.0 + Double(nearestAllowedSemitone)
        return quantizedSemitones / 12.0
    }

    /// Finds the nearest allowed semitone to the given semitone value
    private func findNearestAllowedSemitone(_ semitone: Double) -> Int {
        var minDistance = Double.infinity
        var nearest = 0

        for allowed in allowedSemitones {
            let distance = abs(semitone - Double(allowed))
            if distance < minDistance {
                minDistance = distance
                nearest = allowed
            }
        }

        // Also check wrapping around the octave (e.g., 11.8 might be closer to 0 than 11)
        if let first = allowedSemitones.first {
            let wrapDistance = abs((semitone - 12.0) - Double(first))
            if wrapDistance < minDistance {
                nearest = first
            }
        }

        return nearest
    }
}

// MARK: - Presets
extension Quantizer {
    /// No quantization - passes through all values
    static let none = Quantizer(allowedSemitones: Array(0...11))

    /// Chromatic scale - all semitones
    static let chromatic = Quantizer(allowedSemitones: Array(0...11))

    /// Major scale (Ionian mode)
    static let major = Quantizer(allowedSemitones: [0, 2, 4, 5, 7, 9, 11])

    /// Natural minor scale (Aeolian mode)
    static let minor = Quantizer(allowedSemitones: [0, 2, 3, 5, 7, 8, 10])

    /// Major pentatonic scale
    static let majorPentatonic = Quantizer(allowedSemitones: [0, 2, 4, 7, 9])

    /// Minor pentatonic scale
    static let minorPentatonic = Quantizer(allowedSemitones: [0, 3, 5, 7, 10])

    /// Dorian mode
    static let dorian = Quantizer(allowedSemitones: [0, 2, 3, 5, 7, 9, 10])

    /// Phrygian mode
    static let phrygian = Quantizer(allowedSemitones: [0, 1, 3, 5, 7, 8, 10])

    /// Lydian mode
    static let lydian = Quantizer(allowedSemitones: [0, 2, 4, 6, 7, 9, 11])

    /// Mixolydian mode
    static let mixolydian = Quantizer(allowedSemitones: [0, 2, 4, 5, 7, 9, 10])

    /// Locrian mode
    static let locrian = Quantizer(allowedSemitones: [0, 1, 3, 5, 6, 8, 10])

    /// Harmonic minor scale
    static let harmonicMinor = Quantizer(allowedSemitones: [0, 2, 3, 5, 7, 8, 11])

    /// Whole tone scale
    static let wholeTone = Quantizer(allowedSemitones: [0, 2, 4, 6, 8, 10])

    /// Creates a custom quantizer with the specified semitone offsets
    /// - Parameter semitones: Array of semitone offsets (0-11) within an octave
    /// - Returns: A custom quantizer
    static func custom(_ semitones: [Int]) -> Quantizer {
        let validSemitones = semitones.filter { $0 >= 0 && $0 <= 11 }.sorted()
        return Quantizer(allowedSemitones: validSemitones.isEmpty ? [0] : validSemitones)
    }
}

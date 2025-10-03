//
//  SequencerChannel.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import Foundation

@Observable
class SequencerChannel {
    private var triggerOutput: SequencerTriggerOutput
    private var valueOutput: SequencerValueOutput

    public var valueGrid: [[Double]] = (0..<4).map { _ in
        (0..<4).map { _ in Double.random(in: 0...1) }
    }
    public var position: (x: Int, y: Int) = (0, 0)

    public var accessGrid: [[Bool]] = (0..<4).map { _ in (0..<4).map { _ in true } }
    public var muteGrid: [[Bool]] = (0..<4).map { _ in (0..<4).map { _ in false } }

    public var quantizer: Quantizer = .chromatic

    init(triggerOutput: SequencerTriggerOutput, valueOutput: SequencerValueOutput) {
        self.triggerOutput = triggerOutput
        self.valueOutput = valueOutput
    }
    
    func triggerClock() async {
        handleStepEvent()

        let isMuted = muteGrid[position.x][position.y]
        let rawValue = valueGrid[position.x][position.y]

        // Scale from 0.0-1.0 to 0.0-5.0V
        let scaledValue = rawValue * 5.0

        // Apply quantization
        let quantizedValue = quantizer.quantize(scaledValue)

        // Convert back to 0.0-1.0 range for MIDI CC (0-127 maps to 0.0-5.0V)
        let outputValue = quantizedValue / 5.0

        print("📍 Position: (\(position.x), \(position.y))")
        print("🎚️ Raw: \(String(format: "%.3f", rawValue)) -> Scaled: \(String(format: "%.3f", scaledValue))V -> Quantized: \(String(format: "%.3f", quantizedValue))V -> Output: \(String(format: "%.3f", outputValue))")

        if !isMuted {
            print("🔔 Trigger sent")
        } else {
            print("🔇 Trigger muted")
        }

        do {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await self.valueOutput.sendValue(value: outputValue)
                }
                if !isMuted {
                    group.addTask {
                        try? await self.triggerOutput.sendTrigger()
                    }
                }
            }
        }
    }

    private func handleStepEvent() {
        let startPosition = position
        var candidatePosition = nextPosition(from: position)
        var stepsChecked = 0

        // Keep advancing until we find a position with access or check all 16 positions
        while !accessGrid[candidatePosition.x][candidatePosition.y] && stepsChecked < 16 {
            candidatePosition = nextPosition(from: candidatePosition)
            stepsChecked += 1
        }

        // Only update position if we found an accessible position
        if accessGrid[candidatePosition.x][candidatePosition.y] {
            position = candidatePosition
        }
        // Otherwise, position stays the same (all access spots are false)
    }

    private func nextPosition(from pos: (x: Int, y: Int)) -> (x: Int, y: Int) {
        return (
            x: (pos.x + 1) % 4,
            y: pos.x == 3 ? (pos.y + 1) % 4 : pos.y
        )
    }

    func updateGridValue(x: Int, y: Int, value: Double) {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }
        valueGrid[x][y] = value
    }

    func updateMuteValue(x: Int, y: Int, value: Bool) {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }
        muteGrid[x][y] = value
    }

    func updateAccessValue(x: Int, y: Int, value: Bool) {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }
        accessGrid[x][y] = value
    }

    func playValue(x: Int, y: Int) async {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }

        let rawValue = valueGrid[x][y]

        // Scale from 0.0-1.0 to 0.0-5.0V
        let scaledValue = rawValue * 5.0

        // Apply quantization
        let quantizedValue = quantizer.quantize(scaledValue)

        // Convert back to 0.0-1.0 range for MIDI CC
        let outputValue = quantizedValue / 5.0

        print("🎹 Manual play at (\(x), \(y))")
        print("🎚️ Raw: \(String(format: "%.3f", rawValue)) -> Scaled: \(String(format: "%.3f", scaledValue))V -> Quantized: \(String(format: "%.3f", quantizedValue))V -> Output: \(String(format: "%.3f", outputValue))")
        print("🔔 Trigger sent")

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                try? await self.valueOutput.sendValue(value: outputValue)
            }
            group.addTask {
                try? await self.triggerOutput.sendTrigger()
            }
        }
    }

}

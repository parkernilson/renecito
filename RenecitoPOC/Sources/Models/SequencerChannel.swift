//
//  SequencerChannel.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import Foundation
import MIDIKitCore

@Observable
class SequencerChannel {
    private var triggerOutput: SequencerTriggerOutput
    private var valueOutput: SequencerValueOutput
    private var noteOutput: SequencerNoteOutput

    // TODO: add a randomize button to channel values

    // The voltage range of MIDI CC to cv converter
    // i.e. 5 means that cc values from 0 to 1 will output voltages between 0v and 5v
    private let outputCCRangeInVolts = 5

    public var valueGrid: [[Double]] = (0..<4).map { _ in
        (0..<4).map { _ in Double.random(in: 0...1) }
    }
    public var position: (x: Int, y: Int) = (0, 0)

    public var accessGrid: [[Bool]] = (0..<4).map { _ in
        (0..<4).map { _ in true }
    }
    public var muteGrid: [[Bool]] = (0..<4).map { _ in
        (0..<4).map { _ in false }
    }

    public var quantizer: Quantizer = .none
    public var snakePattern: SnakePattern = .rows

    init(
        triggerOutput: SequencerTriggerOutput,
        valueOutput: SequencerValueOutput,
        noteOutput: SequencerNoteOutput
    ) {
        self.triggerOutput = triggerOutput
        self.valueOutput = valueOutput
        self.noteOutput = noteOutput
    }

    func triggerClock() async {
        handleStepEvent()
        print("📍 Position: (\(position.x), \(position.y))")

        let isMuted = muteGrid[position.x][position.y]
        let (outputCCValue, outputQuantizedNote) = getOutputValues(for: position)

        await sendEvent(outputCCValue: outputCCValue, outputQuantizedNote: outputQuantizedNote, withTrigger: !isMuted)
    }
    
    private func getOutputValues(for position: (x: Int, y: Int)) -> (ccValue: Double?, quantizedNote: MIDINote?) {
        let rawValue = valueGrid[position.x][position.y]

        // Scale from 0.0-1.0 to 0.0-5.0V
        // This represents the full voltage output range now
        let valueInVoltageRange = rawValue * 5.0

        var outputCCValue: Double?
        var outputQuantizedNote: MIDINote?

        if quantizer == .none {
            // If there is no quantizer and we want smooth values, use CC instead because
            // it allows for more granularity

            // Convert back to 0.0-1.0 range for MIDI CC (0.0-1.0 maps to 0-127 which maps to 0.0-5.0V output)
            outputCCValue =
                valueInVoltageRange / Double(outputCCRangeInVolts)
            print(
                "🎚️ Raw: \(String(format: "%.3f", rawValue)) -> Volts: \(String(format: "%.3f", valueInVoltageRange))V -> CC Value (0.0-1.0): \(String(format: "%.3f", outputCCValue!))"
            )
        } else {
            // Apply quantization
            outputQuantizedNote = MIDINote(
                quantizer.getQuantizedNote(
                    valueInVoltageRange
                )
            )
            print(
                "🎚️ Raw: \(String(format: "%.3f", rawValue)) -> Volts: \(String(format: "%.3f", valueInVoltageRange))V -> Quantized Note Num: \(outputQuantizedNote!)"
            )
        }
        
        return (outputCCValue, outputQuantizedNote)
    }
    
    private func sendEvent(outputCCValue: Double? = nil, outputQuantizedNote: MIDINote? = nil, withTrigger: Bool = false) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if let outputCCValue = outputCCValue {
                    try? await self.valueOutput.sendValue(
                        value: outputCCValue
                    )
                }
                if let outputQuantizedNote = outputQuantizedNote {
                    try? await self.noteOutput.sendNewNote(
                        note: outputQuantizedNote
                    )
                }
            }
            if withTrigger {
                print("🔔 Trigger sent")
                group.addTask {
                    try? await self.triggerOutput.sendTrigger()
                }
            } else {
                print("🔇 Trigger Muted")
            }
        }
    }

    private func handleStepEvent() {
        //        let startPosition = position
        var candidatePosition = nextPosition(from: position)
        var stepsChecked = 0

        // Keep advancing until we find a position with access or check all 16 positions
        while !accessGrid[candidatePosition.x][candidatePosition.y]
            && stepsChecked < 16
        {
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
        return snakePattern.nextPosition(from: pos)
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
        let (outputCCValue, outputQuantizedNote) = getOutputValues(for: (x: x, y: y))
        await sendEvent(outputCCValue: outputCCValue, outputQuantizedNote: outputQuantizedNote, withTrigger: true)
    }

}

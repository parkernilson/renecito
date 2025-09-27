//
//  MidiSequencer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/27/25.
//

import Foundation
import MIDIKitIO

enum MidiSequencerOutput {
    case output1

    init(_ sequencerOutput: SequencerOutput) {
        switch sequencerOutput {
        case .output1: self = .output1
        }
    }

    func midiEvent(value: Double) -> MIDIEvent {
        switch self {
        case .output1:
            return MIDIEvent.cc(1, value: .unitInterval(value), channel: 0)
        }
    }
}

// TODO: eventually when we create the UI for sequencer, I will probably need to create an ObservableMidiSequencer that
// has all the state that the ui reacts to. Then it will play the sequencer using methods on the MidiSequencer.
// I wanted to do it this way for testability and separation of concerns.

// TODO: figure out how to represent a concept of tempo so that transitions can be adapted to musical tempos

class MidiSequencer: Sequencer {
    private let midiManager: ObservableMIDIManager

    init(midiManager: ObservableMIDIManager) {
        self.midiManager = midiManager
    }

    func sendValue(_ value: Double, to output: SequencerOutput) {
        let midiOutput = MidiSequencerOutput(output)
        let midiEvent = midiOutput.midiEvent(value: value)

        // Send through the output connection
        if let outputConnection = midiManager.managedOutputConnections[MIDIHelper.Tags.midiOut] {
            try? outputConnection.send(event: midiEvent)
        } else {
            print("No MIDI output connection available")
        }
    }
}

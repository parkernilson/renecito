//
//  SequencerOutput.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

class SequencerTriggerOutput {
    private var midi: MIDIHelper
    private var channel: UInt4

    init(midi: MIDIHelper, channel: UInt4) {
        self.midi = midi
        self.channel = channel
    }

    func sendTrigger() async throws {
        try self.midi.midiOutputConnection?.send(
            event: .noteOn(
                60,
                velocity: .unitInterval(1),
                channel: self.channel
            )
        )
        try await Task.sleep(for: .milliseconds(10))
        try self.midi.midiOutputConnection?.send(
            event: .noteOff(
                60,
                velocity: .unitInterval(1),
                channel: self.channel
            )
        )
    }
}

class SequencerValueOutput {
    private var midi: MIDIHelper
    private var channel: UInt4
    private var controller: MIDIEvent.CC.Controller
    private var lastValue: Double?
    private var curValue: Double?
    private var targetValue: Double?

    init(midi: MIDIHelper, channel: UInt4, controller: MIDIEvent.CC.Controller)
    {
        self.midi = midi
        self.channel = channel
        self.controller = controller
    }

    func sendValue(value: Double) throws {
        curValue = value
        try self.midi.midiOutputConnection?.send(
            event: .cc(
                self.controller,
                value: .unitInterval(value),
                channel: self.channel
            )
        )
    }

    func sendValueSmooth(value: Double, duration: Double) async throws {
        if curValue == nil { curValue = 0 }
        lastValue = curValue
        targetValue = value
        for await t in AsyncTransition.transition(duration: duration) {
            Task {
                try sendValue(
                    value: lastValue! + t * (targetValue! - lastValue!)
                )
            }
        }
    }
}

class SequencerNoteOutput {
    private var midi: MIDIHelper
    private var channel: UInt4
    private var lastNote: MIDINote?

    init(midi: MIDIHelper, channel: UInt4) {
        self.midi = midi
        self.channel = channel
    }

    func sendNewNote(note: MIDINote) throws {
        if let lastNote = lastNote {
            try self.midi.midiOutputConnection?.send(
                event: .noteOff(
                    lastNote,
                    velocity: .unitInterval(1),
                    channel: self.channel
                )
            )
        }
        lastNote = note
        try self.midi.midiOutputConnection?.send(
            event: .noteOn(
                note,
                velocity: .unitInterval(1),
                channel: self.channel
            )
        )
    }
}

extension SequencerTriggerOutput {
    static func xChannelTriggerOutput(midi: MIDIHelper)
        -> SequencerTriggerOutput
    {
        SequencerTriggerOutput(midi: midi, channel: 0)
    }

    static func yChannelTriggerOutput(midi: MIDIHelper)
        -> SequencerTriggerOutput
    {
        SequencerTriggerOutput(midi: midi, channel: 1)
    }
}

extension SequencerValueOutput {
    static func xChannelValueOutput(midi: MIDIHelper) -> SequencerValueOutput {
        SequencerValueOutput(midi: midi, channel: 0, controller: .modWheel)
    }

    static func yChannelValueOutput(midi: MIDIHelper) -> SequencerValueOutput {
        SequencerValueOutput(midi: midi, channel: 1, controller: .expression)
    }
}

extension SequencerNoteOutput {
    static func xChannelNoteOutput(midi: MIDIHelper) -> SequencerNoteOutput {
        SequencerNoteOutput(midi: midi, channel: 0)
    }
    
    static func yChannelNoteOutput(midi: MIDIHelper) -> SequencerNoteOutput {
        SequencerNoteOutput(midi: midi, channel: 1)
    }
}

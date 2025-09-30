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

    init(midi: MIDIHelper, channel: UInt4, controller: MIDIEvent.CC.Controller) {
        self.midi = midi
        self.channel = channel
        self.controller = controller
    }

    func sendValue(value: Double) async throws {
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
                try await sendValue(value: lastValue! + t * (targetValue! - lastValue!))
            }
        }
    }
}

extension SequencerTriggerOutput {
    static func xChannelTriggerOutput(midi: MIDIHelper) -> SequencerTriggerOutput {
        SequencerTriggerOutput(midi: midi, channel: 0)
    }

    static func yChannelTriggerOutput(midi: MIDIHelper) -> SequencerTriggerOutput {
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

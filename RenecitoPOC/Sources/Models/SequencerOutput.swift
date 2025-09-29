//
//  SequencerOutput.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

// TODO: I think I should have a SequencerOutput protocol
// then extensions for TriggerOutput, ValueOutput
// then static factory functions for xChannelValueOutput, xChannelTriggerOutput, etc.

class SequencerOutput {
    private var midi: MIDIHelper
    private var channel: UInt4
    
    init(midi: MIDIHelper, channel: UInt4) {
        self.midi = midi
        self.channel = channel
    }

    func sendValueSmooth(value: Double, duration: Double) async throws {
        for await progress in AsyncTransition.transition(duration: duration) {
            try await sendValue(value: progress)
        }
    }
    
    func sendValue(value: Double) async throws {
        try self.midi.midiOutputConnection?.send(
            event: .cc(
                1,
                value: .unitInterval(value),
                channel: self.channel
            )
        )
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

extension SequencerOutput {
    static func xChannelValueOutput(midi: MIDIHelper) -> SequencerOutput {
        SequencerOutput(midi: midi, channel: 0)
    }
}

//
//  Output1.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

class Output1 : SequencerOutput {
    private var midi: MIDIHelper
    
    init(midi: MIDIHelper) {
        self.midi = midi
    }
    
    func sendTrigger() async throws {
        print("Sending noteOn event as a result of trigger")
        try self.midi.midiOutputConnection?.send(
            event: .noteOn(
                60,
                velocity: .midi1(UInt7.random(in: 20...127)),
                channel: 0
            )
        )
    }
}

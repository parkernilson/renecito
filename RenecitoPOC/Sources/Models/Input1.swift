//
//  Input1.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import AsyncAlgorithms
import Foundation
import MIDIKitIO

class Input1: SequencerInput {
    private var midi: MIDIHelper
    private weak var seq: Sequencer?
    
    init(midi: MIDIHelper, sequencer: Sequencer) {
        self.midi = midi
        self.seq = sequencer
    }
    
    // TODO: Make this cancellable (?)
    func listen() async {
        for await event in self.midi.subscribe().filter({ event in event.channel == 0 && event.isChannelVoice(ofType: .noteOn) }) {
            await self.seq?.triggerInput1()
        }
    }
    
    func stop() {
        // TODO: cancel the listen
    }
}

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
        init(midiEventFilter: { event in event.channel == 0 })
        self.midi = midi
        self.seq = sequencer
    }

    func listen() async {
        return await listenInternal { event in
            self.seq?.triggerInput1(event)
        }
    }

}

//
//  Sequencer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

@Observable
class Sequencer {
    private var midi: MIDIHelper
    private var midiListenerID: UUID?
    private var state: SequencerState

    init(midi: MIDIHelper) {
        self.midi = midi
        self.state = .init(midi: midi)
    }

    func start() {
        midiListenerID = self.midi.addListener { [weak self] message in
            if message.isChannelVoice(ofType: .noteOn) && message.channel == 0 {
                Task {
                    await self?.triggerXClock()
                }
            } else if message.isChannelVoice(ofType: .noteOn) && message.channel == 1 {
                Task {
                    await self?.triggerYClock()
                }
            }
        }
    }
    
    func stop() {
        if let id = midiListenerID {
            midi.removeListener(id: id)
            midiListenerID = nil
        }
    }
    
    deinit {
        stop()
    }

    func triggerXClock() async {
        await self.state.triggerXClock()
    }

    func triggerYClock() async {
        await self.state.triggerYClock()
    }
}

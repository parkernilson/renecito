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
    private var listenTask: Task<Void, Never>?

    init(midi: MIDIHelper, sequencer: Sequencer) {
        self.midi = midi
        self.seq = sequencer
    }

    func listen() async {
        print("Input1 listening...")
        listenTask = Task {
            do {
                for await _ in self.midi.subscribe().filter({ event in event.channel == 0 && event.isChannelVoice(ofType: .noteOn) }) {
                    await self.seq?.triggerInput1()
                }
                try Task.checkCancellation()
            } catch {
                if error is CancellationError {
                    print("Input1 listening cancelled")
                } else {
                    print("Input1 listening error: \(error.localizedDescription)")
                }
            }
        }
        await listenTask?.value
    }

    func stop() {
        listenTask?.cancel()
        listenTask = nil
    }

    deinit {
        stop()
        print("Input1 deallocated")
    }
}

//
//  SequencerInput.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

class SequencerInput {
    var listenTask: Task<Void, Never>?
    var midiEventFilter: (MIDIEvent) -> Bool
    
    fileprivate init(midiEventFilter: @escaping (MIDIEvent) -> Bool) {
        self.midiEventFilter = midiEventFilter
    }
    
    func listenInternal(handler: @escaping (MIDIEvent) -> Void) async {
        listenTask = Task {
            for await _ in self.midi.subscribe().filter(self.midiEventFilter) { event in
                handler(event)
            }
        }
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


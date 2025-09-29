//
//  MIDIInput.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

class SequencerInput {
    private let midi: MIDIHelper
    private let filter: @Sendable (MIDIEvent) -> Bool
    private let handler: @Sendable (MIDIEvent) async -> Void
    private var listenTask: Task<Void, Never>?

    init(
        midi: MIDIHelper,
        filter: @escaping @Sendable (MIDIEvent) -> Bool,
        handler: @escaping @Sendable (MIDIEvent) async -> Void
    ) {
        self.midi = midi
        self.filter = filter
        self.handler = handler
    }

    func listen() async {
        listenTask = Task {
            for await event in self.midi.subscribe().filter(self.filter) {
                await self.handler(event)
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
        print("MIDIInput deallocated")
    }
}

//
//  SequencerManager.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation

class SequencerManager {
    private var midi: MIDIHelper
    private var seq: Sequencer
    private var input1: Input1
    private var listenersTask: Task<Void, Never>?

    init(midi: MIDIHelper) {
        self.midi = midi
        self.seq = Sequencer(midi: midi)
        self.input1 = Input1(midi: midi, sequencer: self.seq)
    }

    func start() {
        listenersTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    guard let self = self else { return }
                    await self.input1.listen()
                }

                // Wait for all tasks to complete (or be cancelled)
                for await _ in group {
                    if Task.isCancelled {
                        break
                    }
                }
            }
        }
    }

    func stop() {
        input1.stop()
        listenersTask?.cancel()
        listenersTask = nil
    }

    deinit {
        stop()
        print("SequencerManager deallocated")
    }
}

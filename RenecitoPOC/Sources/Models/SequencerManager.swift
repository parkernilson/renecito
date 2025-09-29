//
//  SequencerManager.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation
import MIDIKitIO

class SequencerManager {
    private var midi: MIDIHelper
    private var seq: Sequencer
    private var listenersTask: Task<Void, Never>?

    private var xClockInput: SequencerInput?
    private var yClockInput: SequencerInput?
    
    init(midi: MIDIHelper) {
        self.midi = midi
        self.seq = Sequencer(midi: midi)
    }

    func start() {
        xClockInput = makeXClockInput()
        yClockInput = makeYClockInput()
        
        listenersTask = Task {
            await withTaskGroup(of: Void.self) { [weak self] group in
                for input in [self?.xClockInput, self?.yClockInput] {
                    group.addTask {
                        await input?.listen()
                    }
                }

                // Wait for all tasks to complete (or be cancelled)
                for await _ in group {
                    if Task.isCancelled {
                        group.cancelAll()
                        break
                    }
                }
            }
        }
    }
    
    func stop() {
        xClockInput?.stop()
        yClockInput?.stop()
        listenersTask?.cancel()
        listenersTask = nil
    }

    deinit {
        stop()
        print("SequencerManager deallocated")
    }
}

extension SequencerManager {
    func makeXClockInput() -> SequencerInput {
        return SequencerInput(
            midi: midi,
            filter: { event in
                event.channel == 0 && event.isChannelVoice(ofType: .noteOn)
            },
            handler: { [weak self] event in
                await self?.seq.triggerXClock()
            }
        )
    }
    
    func makeYClockInput() -> SequencerInput {
        return SequencerInput(
            midi: midi,
            filter: { event in
                event.channel == 1 && event.isChannelVoice(ofType: .noteOn)
            },
            handler: { [weak self] _ in
                await self?.seq.triggerYClock()
            }
        )
    }
}

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
    private var xChannelTriggerOutput: SequencerTriggerOutput
    private var xChannelValueOutput: SequencerValueOutput
    private var midiListenerID: UUID?

    var xChannelValues: [[Double]] = (0..<4).map { _ in
        (0..<4).map { _ in Double.random(in: 0...1) }
    }
    var xChannelPosition: (x: Int, y: Int) = (0, 0)

    init(midi: MIDIHelper) {
        self.midi = midi
        self.xChannelTriggerOutput = SequencerOutput.xChannelTriggerOutput(
            midi: midi
        )
        self.xChannelValueOutput = SequencerOutput.xChannelValueOutput(
            midi: midi
        )
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
        xChannelPosition = (
            x: (xChannelPosition.x + 1) % 4,
            y: xChannelPosition.x == 3
                ? (xChannelPosition.y + 1) % 4 : xChannelPosition.y
        )

        print("X Clock Triggered")
        print("X Position: \(self.xChannelPosition)")

        do {
            print(
                "Sending value: \(xChannelValues[xChannelPosition.x][xChannelPosition.y])"
            )
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await self.xChannelValueOutput.sendValueSmooth(
                        value: self.xChannelValues[self.xChannelPosition.x][
                            self.xChannelPosition.y
                        ],
                        duration: 0.05
                    )
                }
                group.addTask {
                    try? await self.xChannelTriggerOutput.sendTrigger()
                }
            }
        }
    }

    func triggerYClock() async {
        print("Y Clock Triggered")
    }
}

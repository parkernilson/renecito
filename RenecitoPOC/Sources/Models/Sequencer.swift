//
//  Sequencer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation

@Observable
class Sequencer {
    private var midi: MIDIHelper
    private var xChannelTriggerOutput: SequencerTriggerOutput
    private var xChannelValueOutput: SequencerValueOutput

    var xChannelValues: [[Double]] = (0..<4).map { _ in (0..<4).map { _ in Double.random(in: 0...1) } }
    var xChannelPosition: (x: Int, y: Int) = (0, 0)
    
    
    init(midi: MIDIHelper) {
        self.midi = midi
        self.xChannelTriggerOutput = SequencerOutput.xChannelTriggerOutput(midi: midi)
        self.xChannelValueOutput = SequencerOutput.xChannelValueOutput(midi: midi)
    }
    
    func triggerXClock() async {
        xChannelPosition = (
            x: (xChannelPosition.x + 1) % 4,
            y: xChannelPosition.x == 3 ? (xChannelPosition.y + 1) % 4 : xChannelPosition.y
        )
        
        print("X Clock Triggered")
        print("X Position: \(self.xChannelPosition)")
        
        do {
            print("Sending value: \(xChannelValues[xChannelPosition.x][xChannelPosition.y])")
            Task {
                try await self.xChannelValueOutput.sendValue(value: xChannelValues[xChannelPosition.x][xChannelPosition.y])
            }
            print("Sending trigger")
            Task {
                try await self.xChannelTriggerOutput.sendTrigger()
            }
        } catch {
            print("Error sending trigger to output1:", error.localizedDescription)
        }
    }
    
    func triggerYClock() async {
        print("Y Clock Triggered")
    }

    deinit {
        print("Sequencer deallocated")
    }
}

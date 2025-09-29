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
    
    init(midi: MIDIHelper) {
        self.midi = midi
        // TODO: refactor to use protocols and factory methods
        self.xChannelTriggerOutput = SequencerOutput.xChannelTriggerOutput(midi: midi)
        self.xChannelValueOutput = SequencerOutput.xChannelValueOutput(midi: midi)
    }
    
    func triggerXClock() async {
        // TODO: implement sequencer state machine
        do {
            try await self.output1.sendTrigger()
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

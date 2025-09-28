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
    private var output1: Output1
    
    init(midi: MIDIHelper) {
        self.midi = midi
        self.output1 = Output1(midi: midi)
    }
    
    func triggerInput1() async {
        do {
            try await self.output1.sendTrigger()
        } catch {
            print("Error sending trigger to output1:", error.localizedDescription)
        }
    }
}

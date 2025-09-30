//
//  SequencerState.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import Foundation

@Observable
class SequencerState {
    private var xChannel: SequencerChannel
    private var yChannel: SequencerChannel
    
    init(midi: MIDIHelper) {
        self.xChannel = SequencerChannel(
            triggerOutput: SequencerTriggerOutput.xChannelTriggerOutput(midi: midi),
            valueOutput: SequencerValueOutput.xChannelValueOutput(midi: midi)
        )
        self.yChannel = SequencerChannel(
            triggerOutput: SequencerTriggerOutput.yChannelTriggerOutput(midi: midi),
            valueOutput: SequencerValueOutput.yChannelValueOutput(midi: midi)
        )
    }
    
    func triggerXClock() async {
        await self.xChannel.triggerClock()
    }
    
    func triggerYClock() async {
        await self.yChannel.triggerClock()
    }
}

//
//  SequencerState.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import Foundation

@Observable
class SequencerState {
    public var xChannel: SequencerChannel
    public var yChannel: SequencerChannel
    
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

    func updateXChannelGridValue(x: Int, y: Int, value: Double) {
        xChannel.updateGridValue(x: x, y: y, value: value)
    }

    func updateYChannelGridValue(x: Int, y: Int, value: Double) {
        yChannel.updateGridValue(x: x, y: y, value: value)
    }

    func updateXChannelMuteValue(x: Int, y: Int, value: Bool) {
        xChannel.updateMuteValue(x: x, y: y, value: value)
    }

    func updateYChannelMuteValue(x: Int, y: Int, value: Bool) {
        yChannel.updateMuteValue(x: x, y: y, value: value)
    }

    func updateXChannelAccessValue(x: Int, y: Int, value: Bool) {
        xChannel.updateAccessValue(x: x, y: y, value: value)
    }

    func updateYChannelAccessValue(x: Int, y: Int, value: Bool) {
        yChannel.updateAccessValue(x: x, y: y, value: value)
    }

    func updateXChannelQuantizer(_ quantizer: Quantizer) {
        xChannel.quantizer = quantizer
    }

    func updateYChannelQuantizer(_ quantizer: Quantizer) {
        yChannel.quantizer = quantizer
    }

    func playXChannelValue(x: Int, y: Int) async {
        await xChannel.playValue(x: x, y: y)
    }

    func playYChannelValue(x: Int, y: Int) async {
        await yChannel.playValue(x: x, y: y)
    }
}

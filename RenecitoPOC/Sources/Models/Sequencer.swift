//
//  Sequencer.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/27/25.
//

import Foundation

enum SequencerInput {
    case input1
}

enum SequencerOutput {
    case output1
}

protocol Sequencer {
    func sendValue(_ value: Double, to output: SequencerOutput)
}

extension Sequencer {
    func triggerInput(_ input: SequencerInput) {
        // Can call sendValue here since it's required by the protocol
        sendValue(1.0, to: .output1)
    }

    func sendValueTransition(
        _ output: SequencerOutput,
        duration: TimeInterval = 1.0,
        frameRate: Double = 60.0,
        bezierCurve: BezierCurve = .easeInOut
    ) async {
        for await value in AsyncTransition.transition(
            duration: duration,
            frameRate: frameRate,
            bezierCurve: bezierCurve
        ) {
            sendValue(value, to: output)
        }
    }
}

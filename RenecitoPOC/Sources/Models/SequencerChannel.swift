//
//  SequencerChannel.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import Foundation

@Observable
class SequencerChannel {
    private var triggerOutput: SequencerTriggerOutput
    private var valueOutput: SequencerValueOutput

    public var valueGrid: [[Double]] = (0..<4).map { _ in
        (0..<4).map { _ in Double.random(in: 0...1) }
    }
    public var position: (x: Int, y: Int) = (0, 0)

    public var accessGrid: [[Bool]]
    public var muteGrid: [[Bool]]

    init(triggerOutput: SequencerTriggerOutput, valueOutput: SequencerValueOutput) {
        self.triggerOutput = triggerOutput
        self.valueOutput = valueOutput
        self.accessGrid = (0..<4).map { _ in (0..<4).map { _ in true } }
        self.muteGrid = (0..<4).map { _ in (0..<4).map { _ in false } }
    }
    
    func triggerClock() async {
        position = (
            x: (position.x + 1) % 4,
            y: position.x == 3
                ? (position.y + 1) % 4 : position.y
        )

        let isMuted = muteGrid[position.x][position.y]

        do {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await self.valueOutput.sendValue(
                        value: self.valueGrid[self.position.x][
                            self.position.y
                        ]
                    )
                }
                if !isMuted {
                    group.addTask {
                        try? await self.triggerOutput.sendTrigger()
                    }
                }
            }
        }
    }

    func updateGridValue(x: Int, y: Int, value: Double) {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }
        valueGrid[x][y] = value
    }

}

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

    public var grid: [[Double]] = (0..<4).map { _ in
        (0..<4).map { _ in Double.random(in: 0...1) }
    }
    public var position: (x: Int, y: Int) = (0, 0)
    
    init(triggerOutput: SequencerTriggerOutput, valueOutput: SequencerValueOutput) {
        self.triggerOutput = triggerOutput
        self.valueOutput = valueOutput
    }
    
    func triggerClock() async {
        position = (
            x: (position.x + 1) % 4,
            y: position.x == 3
                ? (position.y + 1) % 4 : position.y
        )

        do {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await self.valueOutput.sendValue(
                        value: self.grid[self.position.x][
                            self.position.y
                        ],
                    )
                }
                group.addTask {
                    try? await self.triggerOutput.sendTrigger()
                }
            }
        }
    }

    func updateGridValue(x: Int, y: Int, value: Double) {
        guard x >= 0 && x < 4 && y >= 0 && y < 4 else { return }
        grid[x][y] = value
    }

}

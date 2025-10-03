//
//  SnakePattern.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 10/2/25.
//

import Foundation

class SnakePattern {
    private let jumpMap: [String: (x: Int, y: Int)]
    let id: String

    private init(id: String, jumpMap: [String: (x: Int, y: Int)]) {
        self.id = id
        self.jumpMap = jumpMap
    }

    func nextPosition(from pos: (x: Int, y: Int)) -> (x: Int, y: Int) {
        let key = "\(pos.x),\(pos.y)"
        return jumpMap[key] ?? pos
    }

    static let rows = SnakePattern(id: "rows", jumpMap: [
        "0,0": (1,0), "1,0": (2,0), "2,0": (3,0), "3,0": (0,1),
        "0,1": (1,1), "1,1": (2,1), "2,1": (3,1), "3,1": (0,2),
        "0,2": (1,2), "1,2": (2,2), "2,2": (3,2), "3,2": (0,3),
        "0,3": (1,3), "1,3": (2,3), "2,3": (3,3), "3,3": (0,0)
    ])

    static let columns = SnakePattern(id: "columns", jumpMap: [
        "0,0": (0,1), "0,1": (0,2), "0,2": (0,3), "0,3": (1,0),
        "1,0": (1,1), "1,1": (1,2), "1,2": (1,3), "1,3": (2,0),
        "2,0": (2,1), "2,1": (2,2), "2,2": (2,3), "2,3": (3,0),
        "3,0": (3,1), "3,1": (3,2), "3,2": (3,3), "3,3": (0,0)
    ])

    static let wideSnake = SnakePattern(id: "wideSnake", jumpMap: [
        "0,0": (1,0), "1,0": (2,0), "2,0": (3,0), "3,0": (3,1),
        "3,1": (2,1), "2,1": (1,1), "1,1": (0,1), "0,1": (0,2),
        "0,2": (1,2), "1,2": (2,2), "2,2": (3,2), "3,2": (3,3),
        "3,3": (2,3), "2,3": (1,3), "1,3": (0,3), "0,3": (0,0)
    ])

    static let tallSnake = SnakePattern(id: "tallSnake", jumpMap: [
        "0,0": (0,1), "0,1": (0,2), "0,2": (0,3), "0,3": (1,3),
        "1,3": (1,2), "1,2": (1,1), "1,1": (1,0), "1,0": (2,0),
        "2,0": (2,1), "2,1": (2,2), "2,2": (2,3), "2,3": (3,3),
        "3,3": (3,2), "3,2": (3,1), "3,1": (3,0), "3,0": (0,0)
    ])
}

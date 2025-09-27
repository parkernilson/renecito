//
//  AsyncTransition.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/27/25.
//

import Foundation

struct AsyncTransition {

    static func transition(
        duration: TimeInterval = 1.0,
        frameRate: Double = 60.0,
        bezierCurve: BezierCurve = .easeInOut
    ) -> AsyncStream<Double> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    let frameInterval = 1.0 / frameRate
                    let totalFrames = Int(duration * frameRate)

                    for frame in 0...totalFrames {
                        try Task.checkCancellation()

                        let progress = Double(frame) / Double(totalFrames)
                        let easedProgress = bezierCurve.apply(progress)
                        let clampedValue = max(0.0, min(1.0, easedProgress))

                        continuation.yield(clampedValue)

                        if frame < totalFrames {
                            try await Task.sleep(for: .nanoseconds(UInt64(frameInterval * 1_000_000_000)))
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

enum BezierCurve {
    case easeInOut
    case easeIn
    case easeOut
    case linear
    case custom((Double) -> Double)

    nonisolated func apply(_ t: Double) -> Double {
        switch self {
        case .easeInOut:
            return t * t * (3.0 - 2.0 * t)
        case .easeIn:
            return t * t
        case .easeOut:
            return 1.0 - (1.0 - t) * (1.0 - t)
        case .linear:
            return t
        case .custom(let function):
            return function(t)
        }
    }
}

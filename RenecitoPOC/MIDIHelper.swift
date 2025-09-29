import AsyncAlgorithms
import MIDIKitIO
import SwiftUI

/// Receiving MIDI happens on an asynchronous background thread. That means it cannot update
/// SwiftUI view state directly. Therefore, we need a helper class marked with `@Observable`
/// which contains properties that SwiftUI can use to update views.
actor MIDIBroadcaster {
    private var continuations: [ObjectIdentifier: AsyncStream<MIDIEvent>.Continuation] = [:]

    func addSubscriber(_ continuation: AsyncStream<MIDIEvent>.Continuation) -> ObjectIdentifier {
        let id = ObjectIdentifier(continuation as AnyObject)
        continuations[id] = continuation
        return id
    }

    func removeSubscriber(withId id: ObjectIdentifier) {
        continuations.removeValue(forKey: id)
    }

    func broadcast(_ event: MIDIEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    func finishAll() {
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }
}

@Observable @MainActor final class MIDIHelper {
    private let broadcaster = MIDIBroadcaster()
    private weak var midiManager: ObservableMIDIManager?
    private let maxEvents = 1000

    public private(set) var receivedEvents: [MIDIEvent] = []

    public var filterActiveSensingAndClock = false
    
    public init() { }
    
    public func setup(midiManager: ObservableMIDIManager) {
        self.midiManager = midiManager

        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }

        do {
            try midiManager.addInputConnection(
                to: .none,
                tag: Tags.midiIn,
                receiver: .events { [weak self] events, timeStamp, source in
                    Task { @MainActor in
                        self?.received(events: events)
                    }
                }
            )

            try midiManager.addOutputConnection(
                to: .none,
                tag: Tags.midiOut
            )
        } catch {
            print("Error creating MIDI connections:", error.localizedDescription)
        }
    }
    
    // MARK: Common Event Receiver
    
    private func received(events: [MIDIEvent]) {
        let events = filterActiveSensingAndClock
            ? events.filter(sysRealTime: .dropTypes([.activeSensing, .timingClock]))
            : events
        
        print("Received events: \(events)")
        
        // must update properties that result in UI changes on main thread
        Task { @MainActor in
            self.receivedEvents.append(contentsOf: events)

            // Keep only the most recent events to prevent unbounded growth
            if self.receivedEvents.count > self.maxEvents {
                let excess = self.receivedEvents.count - self.maxEvents
                self.receivedEvents.removeFirst(excess)
            }
        }
        
        Task {
            for event in events {
                await self.broadcaster.broadcast(event)
            }
        }
    }
    
    nonisolated func subscribe() -> AsyncStream<MIDIEvent> {
        let broadcaster = self.broadcaster
        return AsyncStream<MIDIEvent> { continuation in
            Task {
                let subscriberId = await broadcaster.addSubscriber(continuation)

                continuation.onTermination = { _ in
                    Task {
                        await broadcaster.removeSubscriber(withId: subscriberId)
                    }
                }
            }
        }
    }

    deinit {
        let broadcaster = self.broadcaster
        Task.detached {
            await broadcaster.finishAll()
        }
        print("MIDIHelper deallocated")
    }
    
    // MARK: - MIDI Input Connection
    
    public var midiInputConnection: MIDIInputConnection? {
        midiManager?.managedInputConnections[Tags.midiIn]
    }
    
    // MARK: - MIDI Output Connection
    
    public var midiOutputConnection: MIDIOutputConnection? {
        midiManager?.managedOutputConnections[Tags.midiOut]
    }
}

// MARK: - String Constants

extension MIDIHelper {
    enum Tags {
        static let midiIn = "SelectedInputConnection"
        static let midiOut = "SelectedOutputConnection"
    }
    
    enum PrefKeys {
        static let midiInID = "SelectedMIDIInID"
        static let midiInDisplayName = "SelectedMIDIInDisplayName"
        
        static let midiOutID = "SelectedMIDIOutID"
        static let midiOutDisplayName = "SelectedMIDIOutDisplayName"
    }
    
    enum Defaults {
        static let selectedDisplayName = "None"
    }
}


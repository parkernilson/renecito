import AsyncAlgorithms
import MIDIKitIO
import SwiftUI

/// Receiving MIDI happens on an asynchronous background thread. That means it cannot update
/// SwiftUI view state directly. Therefore, we need a helper class marked with `@Observable`
/// which contains properties that SwiftUI can use to update views.

@Observable @MainActor final class MIDIHelper {
    private let channel = AsyncChannel<MIDIEvent>()
    private weak var midiManager: ObservableMIDIManager?
    
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
        
        // must update properties that result in UI changes on main thread
        Task { @MainActor in
            self.receivedEvents.append(contentsOf: events)
        }
        
        Task {
            for event in events {
                await self.channel.send(event)
            }
        }
    }
    
    // Each call returns a NEW independent iterator
    nonisolated func subscribe() -> AsyncChannel<MIDIEvent> {
        channel
    }
    
    func finish() async {
        channel.finish()
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


import MIDIKitIO
import SwiftUI

final class MIDIHelper {
    private weak var midiManager: MIDIManager?
    private var listeners: [(MIDIEvent) -> Void] = []
    
    public init() { }
    
    public func setup(midiManager: MIDIManager) {
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
                    Task {
                        await self?.received(events: events)
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
        for event in events {
            listeners.forEach { $0(event) }
        }
    }

    public func addListener(_ listener: @escaping (MIDIEvent) -> Void) {
        listeners.append(listener)
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


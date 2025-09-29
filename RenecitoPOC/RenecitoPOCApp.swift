//
//  RenecitoPOCApp.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/23/25.
//

import SwiftUI
import MIDIKitIO

@main
struct RenecitoPOCApp: App {
    @State var midiManager = ObservableMIDIManager(
        clientName: "TestAppMIDIManager",
        model: "TestApp",
        manufacturer: "MyCompany"
    )
    
    @State var midiHelper = MIDIHelper()
//    var sequencerManager: SequencerManager?
    
    @AppStorage(MIDIHelper.PrefKeys.midiInID)
    var midiInSelectedID: MIDIIdentifier?
    
    @AppStorage(MIDIHelper.PrefKeys.midiInDisplayName)
    var midiInSelectedDisplayName: String?
    
    @AppStorage(MIDIHelper.PrefKeys.midiOutID)
    var midiOutSelectedID: MIDIIdentifier?
    
    @AppStorage(MIDIHelper.PrefKeys.midiOutDisplayName)
    var midiOutSelectedDisplayName: String?
    
    init() {
        midiHelper.setup(midiManager: midiManager)
//        sequencerManager = SequencerManager(midi: midiHelper)
//        sequencerManager?.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                midiInSelectedID: $midiInSelectedID,
                midiInSelectedDisplayName: $midiInSelectedDisplayName,
                midiOutSelectedID: $midiOutSelectedID,
                midiOutSelectedDisplayName: $midiOutSelectedDisplayName
            )
            .environment(midiManager)
            .environment(midiHelper)
        }
    }
}

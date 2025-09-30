//
//  ContentView.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/23/25.
//

import MIDIKitIO
import MIDIKitUI
import SwiftUI

struct ContentView: View {
    @Environment(ObservableMIDIManager.self) private var midiManager
    @Environment(MIDIHelper.self) private var midiHelper
    
    @Binding var midiInSelectedID: MIDIIdentifier?
    @Binding var midiInSelectedDisplayName: String?
    
    @Binding var midiOutSelectedID: MIDIIdentifier?
    @Binding var midiOutSelectedDisplayName: String?
    
    var body: some View {
        NavigationView {
            Form {
                navigationSection
                
                endpointSelectionSection
                
            }
            .navigationBarTitle("Renecito POC")
            
            sequencerView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private var navigationSection: some View {
        Section() {
            NavigationLink("Sequencer") {
                sequencerView
            }
        }
    }
    
    private var sequencerView: some View {
        SequencerView(midi: midiHelper)
    }
    
    private var endpointSelectionSection: some View {
        Section {
            MIDIOutputsPicker(
                title: "MIDI In",
                selectionID: $midiInSelectedID,
                selectionDisplayName: $midiInSelectedDisplayName,
                showIcons: true,
                hideOwned: false
            )
            .updatingInputConnection(withTag: MIDIHelper.Tags.midiIn)
            
            MIDIInputsPicker(
                title: "MIDI Out",
                selectionID: $midiOutSelectedID,
                selectionDisplayName: $midiOutSelectedDisplayName,
                showIcons: true,
                hideOwned: false
            )
            .updatingOutputConnection(withTag: MIDIHelper.Tags.midiOut)
        }
    }
}

extension ContentView {
    private var isMIDIOutDisabled: Bool {
        midiOutSelectedID == .invalidMIDIIdentifier ||
            midiOutSelectedID == nil
    }
    
    func sendToConnection(_ event: MIDIEvent) {
        try? midiHelper.midiOutputConnection?.send(event: event)
    }
}

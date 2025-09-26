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
                infoSection
                
                endpointSelectionSection
                
                eventLogSection
            }
            .navigationBarTitle("Endpoint Pickers")
            
            infoView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private var infoSection: some View {
        Section() {
            NavigationLink("Info") {
                infoView
            }
        }
    }
    
    private var infoView: some View {
        Text(
            """
            This example demonstrates maintaining menus with MIDI endpoints in the system, allowing a single selection for each menu.
            
            Refer to this example's README.md file for important information.
            
            For testing purposes, try creating virtual endpoints, selecting them as MIDI In and MIDI Out, then destroying them. They appear as missing but their selection is retained. Then create them again, and they will appear normally once again and connection will resume. They are remembered even if you quit the app.
            """
        )
        .multilineTextAlignment(.center)
        .navigationTitle("Info")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: 600)
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
    
    @ViewBuilder
    private var eventLogSection: some View {
        @Bindable var midiHelper = midiHelper
        
        Section(header: Text("Received Events")) {
            Toggle(
                "Filter Active Sensing and Clock",
                isOn: $midiHelper.filterActiveSensingAndClock
            )
            
            let events = midiHelper.receivedEvents.reversed()
            
            // Since MIDIEvent doesn't conform to Identifiable (and won't ever), in a List
            // or ForEach we need to either use an array index or a wrap MIDIEvent in a
            // custom type that does conform to Identifiable. It's really up to your use
            // case.
            // Usually application interaction is driven by MIDI events and we aren't
            // literally logging events, but this is for diagnostic purposes here.
            List(events.indices, id: \.self) { index in
                Text(events[index].description)
                    .foregroundColor(color(for: events[index]))
            }
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
    
    func color(for event: MIDIEvent) -> Color? {
        switch event {
        case .noteOn: .green
        case .noteOff: .red
        case .cc: .orange
        default: nil
        }
    }
}

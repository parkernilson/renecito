//
//  SequencerView.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import SwiftUI

struct SequencerView: View {
    @State private var sequencerState: SequencerState
    @State private var selectedChannel: ChannelSelection = .x

    init(midi: MIDIHelper) {
        _sequencerState = State(initialValue: SequencerState(midi: midi))
    }

    enum ChannelSelection {
        case x
        case y
    }

    private var currentChannel: SequencerChannel {
        switch selectedChannel {
        case .x:
            return sequencerState.xChannel
        case .y:
            return sequencerState.yChannel
        }
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 4)
    }

    private func sliderView(for row: Int, col: Int) -> some View {
        let binding = Binding(
            get: { currentChannel.valueGrid[col][row] },
            set: { newValue in
                switch selectedChannel {
                case .x:
                    sequencerState.updateXChannelGridValue(
                        x: col,
                        y: row,
                        value: newValue
                    )
                case .y:
                    sequencerState.updateYChannelGridValue(
                        x: col,
                        y: row,
                        value: newValue
                    )
                }
            }
        )

        let isActive =
            currentChannel.position.x == col
            && currentChannel.position.y == row

        return VStack(spacing: 8) {
            Text(String(format: "%.2f", binding.wrappedValue))
                .font(.caption)
                .fontWeight(isActive ? .bold : .regular)
                .foregroundColor(isActive ? .blue : .primary)

            Slider(value: binding, in: 0...1)
                .tint(isActive ? .blue : .gray)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("\(selectedChannel == .x ? "X" : "Y") Channel Sequencer")
                .font(.title)
                .padding()

            Picker("Channel", selection: $selectedChannel) {
                Text("X").tag(ChannelSelection.x)
                Text("Y").tag(ChannelSelection.y)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            LazyVGrid(
                columns: gridColumns,
                spacing: 16
            ) {
                ForEach(0..<16, id: \.self) { index in
                    let row = index / 4
                    let col = index % 4
                    sliderView(for: row, col: col)
                }
            }
            .padding()

            HStack(spacing: 20) {
                Button("Trigger X Clock") {
                    Task {
                        await sequencerState.triggerXClock()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Trigger Y Clock") {
                    Task {
                        await sequencerState.triggerYClock()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(maxWidth: 600)
        .navigationTitle("Sequencer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SequencerView(midi: MIDIHelper())
}


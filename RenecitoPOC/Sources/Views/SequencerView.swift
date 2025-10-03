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
    @State private var selectedSecondaryGrid: SecondaryGridMode = .mute

    init(midi: MIDIHelper) {
        _sequencerState = State(initialValue: SequencerState(midi: midi))
    }

    enum ChannelSelection {
        case x
        case y
    }

    enum SecondaryGridMode {
        case mute
        case access
        case play
    }

    enum QuantizerPreset: String, CaseIterable, Identifiable {
        case none = "None"
        case chromatic = "Chromatic"
        case major = "Major"
        case minor = "Minor"
        case majorPentatonic = "Maj Pent"
        case minorPentatonic = "Min Pent"
        case dorian = "Dorian"
        case phrygian = "Phrygian"
        case lydian = "Lydian"
        case mixolydian = "Mixolydian"
        case locrian = "Locrian"
        case harmonicMinor = "Harm Min"
        case wholeTone = "Whole Tone"

        var id: String { rawValue }

        var quantizer: Quantizer {
            switch self {
            case .none: return .none
            case .chromatic: return .chromatic
            case .major: return .major
            case .minor: return .minor
            case .majorPentatonic: return .majorPentatonic
            case .minorPentatonic: return .minorPentatonic
            case .dorian: return .dorian
            case .phrygian: return .phrygian
            case .lydian: return .lydian
            case .mixolydian: return .mixolydian
            case .locrian: return .locrian
            case .harmonicMinor: return .harmonicMinor
            case .wholeTone: return .wholeTone
            }
        }
    }

    enum SnakePatternOption: String, CaseIterable, Identifiable {
        case rows = "Rows"
        case columns = "Columns"
        case wideSnake = "Wide Snake"
        case tallSnake = "Tall Snake"

        var id: String { rawValue }

        var pattern: SnakePattern {
            switch self {
            case .rows: return SnakePattern.rows
            case .columns: return SnakePattern.columns
            case .wideSnake: return SnakePattern.wideSnake
            case .tallSnake: return SnakePattern.tallSnake
            }
        }
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

    private var quantizerBinding: Binding<QuantizerPreset> {
        Binding(
            get: {
                let currentQuantizer = currentChannel.quantizer
                return QuantizerPreset.allCases.first(where: {
                    $0.quantizer.allowedSemitones == currentQuantizer.allowedSemitones
                }) ?? .chromatic
            },
            set: { newPreset in
                switch selectedChannel {
                case .x:
                    sequencerState.updateXChannelQuantizer(newPreset.quantizer)
                case .y:
                    sequencerState.updateYChannelQuantizer(newPreset.quantizer)
                }
            }
        )
    }

    private var snakePatternBinding: Binding<SnakePatternOption> {
        Binding(
            get: {
                let currentPattern = currentChannel.snakePattern
                return SnakePatternOption.allCases.first(where: {
                    $0.pattern.id == currentPattern.id
                }) ?? .rows
            },
            set: { newOption in
                switch selectedChannel {
                case .x:
                    sequencerState.updateXChannelSnakePattern(newOption.pattern)
                case .y:
                    sequencerState.updateYChannelSnakePattern(newOption.pattern)
                }
            }
        )
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

    private func toggleView(for row: Int, col: Int, mode: SecondaryGridMode) -> some View {
        let binding = Binding(
            get: {
                switch mode {
                case .mute:
                    return currentChannel.muteGrid[col][row]
                case .access:
                    return currentChannel.accessGrid[col][row]
                case .play:
                    return false // Play mode doesn't need state
                }
            },
            set: { newValue in
                switch (selectedChannel, mode) {
                case (.x, .mute):
                    sequencerState.updateXChannelMuteValue(x: col, y: row, value: newValue)
                case (.x, .access):
                    sequencerState.updateXChannelAccessValue(x: col, y: row, value: newValue)
                case (.y, .mute):
                    sequencerState.updateYChannelMuteValue(x: col, y: row, value: newValue)
                case (.y, .access):
                    sequencerState.updateYChannelAccessValue(x: col, y: row, value: newValue)
                case (_, .play):
                    break // Play mode doesn't toggle state
                }
            }
        )

        let isActive =
            currentChannel.position.x == col
            && currentChannel.position.y == row

        return Button(action: {
            if mode == .play {
                // Play the value at this position
                Task {
                    switch selectedChannel {
                    case .x:
                        await sequencerState.playXChannelValue(x: col, y: row)
                    case .y:
                        await sequencerState.playYChannelValue(x: col, y: row)
                    }
                }
            } else {
                binding.wrappedValue.toggle()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(mode == .play ? Color.green.opacity(0.3) : (binding.wrappedValue ? Color.blue : Color.gray.opacity(0.3)))
                    .frame(height: 50)

                if isActive {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(height: 50)
                }

                if mode == .play {
                    Text(String(format: "%.2f", currentChannel.valueGrid[col][row]))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

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

                Picker("Quantizer", selection: quantizerBinding) {
                    ForEach(QuantizerPreset.allCases) { preset in
                        Text(preset.rawValue).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                Picker("Pattern", selection: snakePatternBinding) {
                    ForEach(SnakePatternOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if isLandscape {
                    HStack(spacing: 20) {
                        valueGridView
                        secondaryGridView
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        valueGridView
                        secondaryGridView
                    }
                    .padding()
                }

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
            .navigationTitle("Sequencer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var valueGridView: some View {
        VStack(spacing: 8) {
            Text("Values")
                .font(.headline)

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
        }
    }

    private var secondaryGridView: some View {
        VStack(spacing: 8) {
            Picker("Mode", selection: $selectedSecondaryGrid) {
                Text("Mute").tag(SecondaryGridMode.mute)
                Text("Access").tag(SecondaryGridMode.access)
                Text("Play").tag(SecondaryGridMode.play)
            }
            .pickerStyle(.segmented)

            LazyVGrid(
                columns: gridColumns,
                spacing: 8
            ) {
                ForEach(0..<16, id: \.self) { index in
                    let row = index / 4
                    let col = index % 4
                    toggleView(for: row, col: col, mode: selectedSecondaryGrid)
                }
            }
        }
    }
}

#Preview {
    SequencerView(midi: MIDIHelper())
}


//
//  SequencerView.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/29/25.
//

import SwiftUI

struct SequencerView: View {
    @State private var sequencerState: SequencerState

    init(midi: MIDIHelper) {
        _sequencerState = State(initialValue: SequencerState(midi: midi))
    }

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 4)
    }

    private func dialView(for row: Int, col: Int) -> some View {
        let binding = Binding(
            get: { sequencerState.xChannel.grid[row][col] },
            set: { newValue in
                sequencerState.updateXChannelGridValue(
                    x: row,
                    y: col,
                    value: newValue
                )
            }
        )

        let isActive =
            sequencerState.xChannel.position.x == row
            && sequencerState.xChannel.position.y == col

        return DialView(value: binding, isActive: isActive)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("X Channel Sequencer")
                .font(.title)
                .padding()

            LazyVGrid(
                columns: gridColumns,
                spacing: 16
            ) {
                ForEach(0..<16, id: \.self) { index in
                    let row = index / 4
                    let col = index % 4
                    dialView(for: row, col: col)
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

struct DialView: View {
    @Binding var value: Double
    let isActive: Bool

    private let dialSize: CGFloat = 80

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .foregroundColor(isActive ? .blue : .gray)
                .frame(width: dialSize, height: dialSize)

            Circle()
                .fill(
                    isActive ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                )
                .frame(width: dialSize, height: dialSize)

            VStack(spacing: 4) {
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .fontWeight(isActive ? .bold : .regular)

                Circle()
                    .fill(isActive ? .blue : .gray)
                    .frame(width: 8, height: 8)
            }

            Path { path in
                let center = CGPoint(x: dialSize / 2, y: dialSize / 2)
                path.move(to: center)
                let radius = dialSize / 2 - 8
                let angle = Angle.degrees(Double(value) * 270 - 135)
                let xval = center.x + cos(angle.radians) * radius
                let yval = center.y + sin(angle.radians) * radius
                let endPoint = CGPoint(
                    x: xval,
                    y: yval
                )
                path.addLine(to: endPoint)
            }
            .stroke(isActive ? .blue : .primary, lineWidth: 2)
        }
        .gesture(
            DragGesture()
                .onChanged { dragValue in
                    let center = CGPoint(x: dialSize / 2, y: dialSize / 2)
                    let vector = CGVector(
                        dx: dragValue.location.x - center.x,
                        dy: dragValue.location.y - center.y
                    )

                    let angle = atan2(vector.dy, vector.dx)
                    let normalizedAngle = (angle + .pi * 2).truncatingRemainder(
                        dividingBy: .pi * 2
                    )
                    let degrees = normalizedAngle * 180 / .pi

                    let adjustedDegrees = degrees + 135
                    let clampedDegrees = max(0, min(270, adjustedDegrees))

                    let newValue = clampedDegrees / 270
                    value = newValue
                }
        )
    }
}

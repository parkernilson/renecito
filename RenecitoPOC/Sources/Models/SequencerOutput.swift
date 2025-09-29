//
//  SequencerOutput.swift
//  RenecitoPOC
//
//  Created by Parker Nilson on 9/28/25.
//

import Foundation

protocol SequencerOutput {
    func sendTrigger() async throws
}

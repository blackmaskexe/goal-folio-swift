//
//  Ticker.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//

import Foundation

struct Stock: Identifiable, Hashable, Codable {
    let id = UUID()
    let symbol: String
    let name: String
}

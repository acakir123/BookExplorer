//
//  GenreStat.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

struct GenreStat: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
    
    func percentString(in all: [GenreStat]) -> String {
            let total = all.map { $0.value }.reduce(0, +)
            guard total > 0 else { return "0%" }
            let pct = (value / total) * 100
            return String(format: "%.0f%%", pct)
        }
}

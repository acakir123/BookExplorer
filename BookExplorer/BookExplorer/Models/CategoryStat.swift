//
//  GenreStat.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

// A single statistic category (genre in pie chart & Decade in bar graph)
struct CategoryStat: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
    
    // Helper function to calculate this category's percentage share relative to all others
    func percentString(in all: [CategoryStat]) -> String {
            let total = all.map { $0.value }.reduce(0, +)
            guard total > 0 else { return "0%" }
            let pct = (value / total) * 100
            return String(format: "%.0f%%", pct)
        }
}

//
//  BarChartView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

struct StackedBarChartView: View {
    let data: [CategoryStat]
    let barHeight: CGFloat = 22
    let cornerRadius: CGFloat = 8
    
    // Returns the first 5 categories from data
    private var limited: [CategoryStat] {
        Array(data.prefix(5))
    }
    
    // Cpm[utes the total sum of the selected values
    private var total: Double {
        max(limited.map(\.value).reduce(0, +), 0.0001) // avoid /0
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: Bar
            GeometryReader { geo in
                // Use total width available
                let width = geo.size.width
                
                // HStack of colored rectangles with no spacing
                HStack(spacing: 0) {
                    ForEach(limited) { item in
                        Rectangle()
                            .fill(item.color) // Color filled based on category
                            // Width proportional to percentage of total
                            .frame(width: width * (item.value / total), height: barHeight)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)) // Round edges of combined bar
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5) // thin border
                )
                .frame(height: barHeight, alignment: .center)
            }
            .frame(height: barHeight) // fixes geometry height
            
            // MARK: Label Row
            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 0) {
                    ForEach(limited) { item in
                        // Compute item's proportional width
                        let w = width * (item.value / total)
                        VStack(spacing: 2) {
                            // Category label
                            Text(item.name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            // Percentage below label
                            Text(String(format: "%.0f%%", (item.value / total) * 100))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        // Each label column takes up the same amount of space as its bar
                        .frame(width: w, alignment: .center)
                    }
                }
            }
            .frame(height: 28) // label area height
        }
    }
}

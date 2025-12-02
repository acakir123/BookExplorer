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
    let showZeroPercent: Bool

        init(data: [CategoryStat], showZeroPercent: Bool = false) {
            self.data = data
            self.showZeroPercent = showZeroPercent
        }
    
    // Returns the first 5 categories from data
    private var limited: [CategoryStat] {
        Array(data.prefix(5))
    }
    
    // Cpm[utes the total sum of the selected values
    private var total: Double {
        max(limited.map(\.value).reduce(0, +), 0.0001) // avoid /0
    }
    
    // Max value for vertical bar heights
    private var maxValue: Double {
        max(limited.map(\.value).max() ?? 0, 0.0001) // avoid /0
    }
    
    // Color palette for the bars (separate from the pie colors)
    private let barColors: [Color] = [
        Color(red: 0.24, green: 0.58, blue: 0.98), // blue
        Color(red: 0.99, green: 0.66, blue: 0.26), // orange
        Color(red: 0.45, green: 0.84, blue: 0.39), // green
        Color(red: 0.91, green: 0.32, blue: 0.31), // red
        Color(red: 0.57, green: 0.44, blue: 0.93)  // purple
    ]
    
    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let barAreaHeight = totalHeight * 0.72     // top 72% for bars
            let labelAreaHeight = totalHeight * 0.28   // bottom 28% for labels
            let barWidth = max(geo.size.width / CGFloat(max(limited.count, 1)) - 8, 0)

            VStack(spacing: 4) {
                // MARK: Bars
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(limited.enumerated()), id: \.1.id) { index, item in
                        // Normalize each value to [0,1]
                        let normalized = item.value / maxValue
                        // Scale bar height with bar area
                        let barHeight = barAreaHeight * CGFloat(normalized) * 0.9

                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(barColors[index % barColors.count])
                            .frame(width: barWidth, height: barHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                    }
                }
                .frame(height: barAreaHeight, alignment: .bottom)

                // MARK: Labels
                HStack(alignment: .top, spacing: 8) {
                    ForEach(limited) { item in
                        VStack(spacing: 2) {
                            Text(item.name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Text(
                                showZeroPercent
                                ? "0%"
                                : String(format: "%.0f%%", (item.value / total) * 100)
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: labelAreaHeight, alignment: .top)
            }
        }
    }
}

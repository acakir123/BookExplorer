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
    
    private var limited: [CategoryStat] {
        Array(data.prefix(5))
    }
    private var total: Double {
        max(limited.map(\.value).reduce(0, +), 0.0001) // avoid /0
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Bar
            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 0) {
                    ForEach(limited) { item in
                        Rectangle()
                            .fill(item.color)
                            .frame(width: width * (item.value / total), height: barHeight)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .frame(height: barHeight, alignment: .center)
            }
            .frame(height: barHeight) // fixes geometry height
            
            // Labels under each segment
            GeometryReader { geo in
                let width = geo.size.width
                HStack(spacing: 0) {
                    ForEach(limited) { item in
                        let w = width * (item.value / total)
                        VStack(spacing: 2) {
                            Text(item.name)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            // Optional % below label (comment out if not wanted)
                            Text(String(format: "%.0f%%", (item.value / total) * 100))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: w, alignment: .center)
                    }
                }
            }
            .frame(height: 28) // label area height
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Decade breakdown stacked bar")
    }
}

//
//  PieChartView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

// MARK: Pie chart View
struct PieChartView: View {
    let data: [GenreStat]

    var body: some View {
        GeometryReader { geo in
            let total = data.map(\.value).reduce(0, +)
            // Precompute cumulative slices (no mutation inside ViewBuilder)
            let slices: [(item: GenreStat, start: Double, end: Double)] = {
                var result: [(GenreStat, Double, Double)] = []
                var runningEnd: Double = 0
                for item in data {
                    let frac = total > 0 ? item.value / total : 0
                    let start = runningEnd
                    let end = runningEnd + frac
                    result.append((item, start, end))
                    runningEnd = end
                }
                return result
            }()

            ZStack {
                ForEach(Array(slices.enumerated()), id: \.offset) { _, s in
                    let sliceShape = PieSlice(
                        startAngle: .degrees(s.start * 360),
                        endAngle:   .degrees(s.end   * 360)
                    )
                    sliceShape
                        .fill(s.item.color)
                        .overlay(sliceShape.stroke(Color(.systemBackground).opacity(0.8), lineWidth: 1))
                        .help("\(s.item.name) \(s.item.percentString(in: data))")
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: Pie Slice
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        p.move(to: center)
        p.addArc(center: center,
                 radius: radius,
                 startAngle: startAngle - .degrees(90), // rotate so 0° is at top
                 endAngle: endAngle - .degrees(90),
                 clockwise: false)
        p.closeSubpath()
        return p
    }
}

// MARK: Legend row
struct LegendRow: View {
    let color: Color
    let text: String
    let percent: String
    
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
            
            Text(percent)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(text), \(percent)")
    }
}

//
//  PieChartView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

// MARK: Pie chart View
struct PieChartView: View {
    let data: [CategoryStat]

    var body: some View {
        GeometryReader { geo in
            // Total of all values, used to compute each slices fraction
            let total = data.map(\.value).reduce(0, +)
            
            // Precompute array of slices each with: the original item (for color and name) and a start & end fractional position (between 0 & 1)
            let slices: [(item: CategoryStat, start: Double, end: Double)] = {
                var result: [(CategoryStat, Double, Double)] = []
                var runningEnd: Double = 0 // Cumulative fraction up until current slice
                
                // Iterate in order; each slice occupies a fraction (value / total)
                for item in data {
                    let frac = total > 0 ? item.value / total : 0 // if total = 0, frac = 0
                    let start = runningEnd
                    let end = runningEnd + frac
                    result.append((item, start, end))
                    runningEnd = end
                }
                return result
            }()

            // ZStack draws slices on top of each other in sequence
            // Since slices are non overlapping arcs from center drawing order doesnt matter
            ZStack {
                // Although slice order doesnt matter enumerate slices so that each gets a stable identity
                ForEach(Array(slices.enumerated()), id: \.offset) { _, s in
                    let sliceShape = PieSlice(
                        // Convert fractional [0,1] to degree [0, 360]
                        startAngle: .degrees(s.start * 360),
                        endAngle:   .degrees(s.end   * 360)
                    )
                    // Fill wedge with slice color
                    // Use background color stroke to visually seperate adjacent slices
                    sliceShape
                        .fill(s.item.color)
                        .overlay(sliceShape.stroke(Color(.systemBackground).opacity(0.8), lineWidth: 1))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: Pie Slice
// Draws the actual slices of the pie chart
struct PieSlice: Shape {
    // Start and end angles of wedge (pre 90 degree rotation)
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Center of bounding rect; pie chart center
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // Radois = 1/2 of shortest dimension (keeps the pie a circle)
        let radius = min(rect.width, rect.height) / 2
        
        // Start drawing from center point
        p.move(to: center)
        
        // Draw an arc from start to end angle around the center at the specified radius
        // Subtract 90 degrees so that 0 degrees starts at the top
        p.addArc(center: center,
                 radius: radius,
                 startAngle: startAngle - .degrees(90),
                 endAngle: endAngle - .degrees(90),
                 clockwise: false)
        // Close the subpath (forms a wedge)
        p.closeSubpath()
        return p
    }
}

// MARK: Legend row
// Creates the color, text, and percentage for the legend
struct LegendRow: View {
    let color: Color
    let text: String
    let percent: String
    
    var body: some View {
        HStack(spacing: 10) {
            // Small rounded square to display color
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)
            
            // Label for category
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail) // cut off text to leave room for %
            
            Spacer()
            
            // Percentage of pie chart
            Text(percent)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

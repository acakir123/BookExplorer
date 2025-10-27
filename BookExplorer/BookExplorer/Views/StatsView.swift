//
//  StatsView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

struct StatsView: View {
    // Columns for the 2x2 card grid
    private let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.title2.weight(.semibold))
                    Text("Reading statistics")
                        .font(.title2.weight(.bold))
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                
                // 2x2 Grid of Stat Cards
                LazyVGrid(columns: columns, spacing: 12) {
                    StatCard(title: "# Favorites", text: "45")
                    StatCard(title: "# Genres", text: "12")
                    StatCard(title: "Avg decade", text: "2010s")
                    StatCard(title: "Avg author", text: "JK Rowling")
                }
            }
            .padding(16)
        }
        .background(Color(hex: "E8D6CA"))
    }
}

private struct StatCard: View {
    let title: String
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "FFF8F3"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            VStack(spacing: 6) {
                // “Top-centered” title with a touch of top padding
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(height: 140)
    }
}

//
//  StatsView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

// MARK: Stats View
struct StatsView: View {
    // Columns for the 2x2 card grid
    private let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    
    // MARK: Placeholder data
    private let placeholderGenres: [CategoryStat] = [
        .init(name: "Fantasy",    value: 30, color: Color("Graph1")),
        .init(name: "Sci-Fi",     value: 25, color: Color("Graph2")),
        .init(name: "Mystery",    value: 20, color: Color("Graph3")),
        .init(name: "Non-fiction",value: 15, color: Color("Graph4")),
        .init(name: "Romance",    value: 10, color: Color("Graph5"))
    ]
    
    private let placeholderDecades: [CategoryStat] = [
        .init(name: "1980s", value: 10, color: Color("Graph1")),
        .init(name: "1990s", value: 18, color: Color("Graph2")),
        .init(name: "2000s", value: 22, color: Color("Graph3")),
        .init(name: "2010s", value: 30, color: Color("Graph4")),
        .init(name: "2020s", value: 20, color: Color("Graph5"))
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.title.weight(.semibold))
                    Text("Reading statistics")
                        .font(.title.weight(.bold))
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
                
                // MARK: Genre Breakdown
                Text("Genre breakdown")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 8)

                HStack(alignment: .center, spacing: 16) {
                    // Pie chart
                    PieChartView(data: placeholderGenres)
                        .frame(width: 160, height: 160)
                        .accessibilityLabel("Genre breakdown pie chart")

                    // Chart legend
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(placeholderGenres) { stat in
                            LegendRow(
                                color: stat.color,
                                text: stat.name,
                                percent: stat.percentString(in: placeholderGenres)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color("SecondaryBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // MARK: Decade breakdown
                Text("Decade breakdown")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 8)

                StackedBarChartView(data: placeholderDecades)
                    .frame(height: 70) // bar + labels total height
                    .padding()
                    .background(Color("SecondaryBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(16)
        }
        .background(Color("BackgroundColor"))
    }
}

// MARK: Stat Card
struct StatCard: View {
    let title: String
    let text: String
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("SecondaryBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            VStack(spacing: 0) {
                // Title pinned at top
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("PrimaryBlue"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                
                Spacer() // pushes text to vertical center
                
                // Main centered text
                Text(text)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(.black))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6) // shrink if too long
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 140)
    }
}

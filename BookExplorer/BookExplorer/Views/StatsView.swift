//
//  StatsView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI
import SwiftData

// MARK: Stats View
struct StatsView: View {
    @Query(filter: #Predicate<BookItem> { $0.isFavorite })
    private var favorites: [BookItem]
    
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
        .init(name: "Non-Fiction",value: 15, color: Color("Graph4")),
        .init(name: "Romance",    value: 10, color: Color("Graph5"))
    ]
    
    private let placeholderDecades: [CategoryStat] = [
        .init(name: "1980s", value: 10, color: Color("Graph1")),
        .init(name: "1990s", value: 18, color: Color("Graph2")),
        .init(name: "2000s", value: 22, color: Color("Graph3")),
        .init(name: "2010s", value: 30, color: Color("Graph4")),
        .init(name: "2020s", value: 20, color: Color("Graph5"))
    ]
    
    // MARK: - Derived stats from favorites
    private var favoritesCountText: String {
        "\(favorites.count)"
    }

    private var genresCountText: String {
        let genres = favorites.map { $0.genre ?? "Unknown" }
        return "\(Set(genres).count)"
    }

    private var favoriteDecadeText: String {
        decadeStats.first?.name ?? "—"
    }

    private var favoriteAuthorText: String {
        let grouped = Dictionary(grouping: favorites) { $0.author }
        let top = grouped.max(by: { $0.value.count < $1.value.count })?.key ?? ""
        return top.isEmpty ? "—" : top
    }
    
    private func primaryGenre(for book: BookItem) -> String {
        // Split on comma, trim whitespace
        let parts = book.genre
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard !parts.isEmpty else { return "Unknown" }

        // Take first genre
        var first = parts[0]

        // If it starts with "series:" (case-insensitive), try the next one
        if first.lowercased().hasPrefix("series:") {
            if parts.count > 1 {
                first = parts[1]
            } else {
                return "Unknown"
            }
        }

        let cleaned = first.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? "Unknown" : cleaned
    }

    private var genreStats: [CategoryStat] {
        guard !favorites.isEmpty else { return placeholderGenres }

        let colorNames = ["Graph1", "Graph2", "Graph3", "Graph4", "Graph5"]

        // Group favorites by processed primary genre
        let grouped = Dictionary(grouping: favorites) { book in
            primaryGenre(for: book)
        }

        // Turn into stats, sort by count, keep top 5, then apply colors
        let sorted = grouped
            .map { (name, books) in
                CategoryStat(
                    name: name,
                    value: Double(books.count),
                    color: .clear   // temporary, will set below
                )
            }
            .sorted { $0.value > $1.value }
            .prefix(5)

        return sorted.enumerated().map { index, stat in
            CategoryStat(
                name: stat.name,
                value: stat.value,
                color: Color(colorNames[index % colorNames.count])
            )
        }
    }

    private var decadeStats: [CategoryStat] {
        guard !favorites.isEmpty else { return placeholderDecades }
        
        let colorNames = ["Graph1", "Graph2", "Graph3", "Graph4", "Graph5"]

        let grouped = Dictionary(grouping: favorites) { book -> String in
            let yearString = book.yearPublished

            guard let year = Int(yearString) else {
                return "Unknown"
            }

            let decadeStart = (year / 10) * 10
            return "\(decadeStart)s"
        }

        return grouped
            .enumerated()
            .map { index, entry in
                CategoryStat(
                    name: entry.key,
                    value: Double(entry.value.count),
                    color: Color(colorNames[index % colorNames.count])
                )
            }
            .sorted { $0.value > $1.value }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: Header
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.title.weight(.semibold))
                    Text("Reading Statistics")
                        .font(.title.weight(.bold))
                    Spacer()
                }
                
                // MARK: 2x2 Grid of Stat Cards
                LazyVGrid(columns: columns, spacing: 12) {
                    StatCard(title: "# Favorites", text: favoritesCountText)
                    StatCard(title: "# Genres", text: genresCountText)
                    StatCard(title: "Favorite Decade", text: favoriteDecadeText)
                    StatCard(title: "Favorite Author", text: favoriteAuthorText)
                }
                
                // MARK: Genre Breakdown
                Text("Genre Breakdown")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 8)

                HStack(alignment: .center, spacing: 16) {
                    PieChartView(data: genreStats)
                        .frame(width: 160, height: 160)
                        .accessibilityLabel("Genre breakdown pie chart")

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(genreStats) { stat in
                            LegendRow(
                                color: stat.color,
                                text: stat.name,
                                percent: stat.percentString(in: genreStats)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // MARK: Decade breakdown
                Text("Decade Breakdown")
                   .font(.title2.weight(.semibold))
                   .padding(.top, 8)

               StackedBarChartView(data: decadeStats)
                   .frame(height: 70)
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
            // Secondary Background for card color
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("SecondaryBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
            
            VStack(spacing: 0) {
                // Title
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color("PrimaryBlue"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                
                Spacer() // pushes card text to vertical center
                
                // Main centered text
                Text(text)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(.black))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6) // shrink if too long
                    .lineLimit(1) // One line max
                    .frame(maxWidth: .infinity)
                
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 140)
    }
}

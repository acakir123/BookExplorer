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
    
    // MARK: - Derived stats from favorites
    private var favoritesCountText: String {
        "\(favorites.count)"
    }

    private var genresCountText: String {
        guard !favorites.isEmpty else { return "0" }
        
        let genres = favorites.map { primaryGenre(for: $0) }
        return "\(Set(genres).count)"
    }

    private var favoriteDecadeText: String {
        decadeStats.first?.name ?? "—"
    }

    private var favoriteAuthorText: String {
        // Filter out placeholder values
        let validFavorites = favorites.filter {
            let a = $0.author.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return !a.isEmpty && a != "unknown author" && a != "unknown"
        }

        guard !validFavorites.isEmpty else { return "—" }

        // Group by author
        let grouped = Dictionary(grouping: validFavorites) { $0.author }

        // Turn into (author, count), then sort:
        // 1) higher count first
        // 2) for ties, alphabetical by author
        let best = grouped
            .map { (author: $0.key, count: $0.value.count) }
            .sorted { lhs, rhs in
                if lhs.count != rhs.count {
                    return lhs.count > rhs.count
                }
                return lhs.author < rhs.author
            }
            .first

        return best?.author ?? "—"
    }
    
    // extract a primary genre from a book list of genres
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

    // MARK: genre statistics
    private var genreStats: [CategoryStat] {
        let colorNames = ["Graph1", "Graph2", "Graph3", "Graph4", "Graph5"]
        
        // If no favorites, show 5 empty slices named "—" with value 0
        guard !favorites.isEmpty else {
            return (0..<5).map { index in
                CategoryStat(
                    name: "—",
                    value: 0,
                    color: Color(colorNames[index % colorNames.count])
                )
            }
        }

        // Group favorites by processed primary genre
        let grouped = Dictionary(grouping: favorites) { book in
            primaryGenre(for: book)
        }

        // Turn into stats, sort by count (desc), then name (asc), keep top 5
        let sorted = grouped
            .map { (name, books) in
                CategoryStat(
                    name: name,
                    value: Double(books.count),
                    color: .clear   // temporary, will set below
                )
            }
            .sorted { lhs, rhs in
                if lhs.value != rhs.value {
                    return lhs.value > rhs.value
                }
                return lhs.name < rhs.name
            }
            .prefix(5)

        return sorted.enumerated().map { index, stat in
            CategoryStat(
                name: stat.name,
                value: stat.value,
                color: Color(colorNames[index % colorNames.count])
            )
        }
    }
    
    // MARK: decades statistics
    private var decadeStats: [CategoryStat] {
        let colorNames = ["Graph1", "Graph2", "Graph3", "Graph4", "Graph5"]
        
        // If no favorites, show 5 empty bars named "—" with value 0
        guard !favorites.isEmpty else {
            return (0..<5).map { index in
                CategoryStat(
                    name: "—",
                    value: 0,
                    color: Color(colorNames[index % colorNames.count])
                )
            }
        }

        // Group favorites into decades so 2012 is 2010s
        let grouped = Dictionary(grouping: favorites) { book -> String in
            let yearString = book.yearPublished
            guard let year = Int(yearString) else {
                return "Unknown"
            }
            let decadeStart = (year / 10) * 10
            return "\(decadeStart)s"
        }

        let unsorted = grouped
            .map { (name: $0.key, count: $0.value.count) }

        // sort by count descending and then by label ascending
        let sorted = unsorted.sorted { lhs, rhs in
            if lhs.count != rhs.count {
                return lhs.count > rhs.count
            }
            return lhs.name < rhs.name
        }

        return sorted.enumerated().map { index, entry in
            CategoryStat(
                name: entry.name,
                value: Double(entry.count),
                color: Color(colorNames[index % colorNames.count])
            )
        }
    }
    
    private var genreChartStats: [CategoryStat] {
        // When no favorites, use the same 5 entries but give them value 1
        // so the pie chart can draw a ring, while legend still sees 0s.
        if favorites.isEmpty {
            return genreStats.map { stat in
                CategoryStat(name: stat.name, value: 1, color: stat.color)
            }
        } else {
            return genreStats
        }
    }

    // When no favorites, use the same 5 entries but give them value 1
    // so the bar chart can draw bars , while legend still sees 0s.
    private var decadeChartStats: [CategoryStat] {
        if favorites.isEmpty {
            return decadeStats.map { stat in
                CategoryStat(name: stat.name, value: 1, color: stat.color)
            }
        } else {
            return decadeStats
        }
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
                    PieChartView(data: genreChartStats)
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

                StackedBarChartView(
                    data: decadeChartStats,
                    showZeroPercent: favorites.isEmpty
                )
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

//
//  DetailView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Used to switch back to catalog tab after search similar
    @EnvironmentObject var tabSelection: TabSelection
    
    @Bindable var book: BookItem
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea(edges: .all)
            
            ScrollView {
                VStack {
                    // Cover image
                    coverView
                        .frame(width: 180, height: 300)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(book.title)
                        .font(.title)
                        .foregroundStyle(Color("PrimaryBlue"))
                        .padding()
                    
                    HStack {
                        Spacer()
                        
                        Text(book.author)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(book.genre)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(book.yearPublished)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(book.details)
                        .font(.body)
                        .padding()
                    
                    Button {
                        Task {
                            await searchSimilarAndDismiss()
                        }
                    } label: {
                        Text("Search Similar")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .background(Capsule(style: .continuous))
                    .foregroundStyle(Color("SecondaryBlue"))
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    // Custom back button
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SecondaryBlue"))
                        }
                    }
                    
                    // Favorite button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            book.isFavorite.toggle()
                        } label: {
                            Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SecondaryBlue"))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cover
    
    // Picks remote cover (if available)
    @ViewBuilder
    private var coverView: some View {
        if let urlString = book.coverURL,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackCover
                @unknown default:
                    fallbackCover
                }
            }
        } else {
            fallbackCover
        }
    }
    
    // Falls back to local asset or gray box if no cover
    @ViewBuilder
    private var fallbackCover: some View {
        if !book.coverImage.isEmpty {
            Image(book.coverImage)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray.opacity(0.2)
        }
    }
    
    // Cleans the raw genre string into something usable for a "similar books" query.
    private func cleanedGenreQuery(from raw: String) -> String? {
        // Split on commas and trim whitespace
        let parts = raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        // First non-empty piece
        guard var first = parts.first, !first.isEmpty else {
            return nil
        }

        // If it starts with "series:", try the next piece instead
        if first.lowercased().hasPrefix("series:") {
            if let next = parts.dropFirst().first {
                first = next
            } else {
                return nil
            }
        }

        let cleaned = first.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = cleaned.lowercased()

        // Ignore placeholder genres
        if cleaned.isEmpty || lower.hasPrefix("unknown") {
            return nil
        }

        return cleaned
    }
    
    // MARK: - Search Similar
    
    private func searchSimilarAndDismiss() async {
        // Build a good genre query if possible; otherwise fall back to title only
        let genreQuery = cleanedGenreQuery(from: book.genre)

        do {
            let docs = try await OpenLibraryAPI.shared.searchSimilarBooks(
                title: book.title,
                genre: genreQuery,   // cleaned or nil
                limit: 10
            )
            try await syncBooksFromOpenLibrary(docs, in: modelContext)
        } catch {
            print("Error searching similar books:", error)
        }

        await MainActor.run {
            tabSelection.selectedTab = .catalog
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: BookItem.self, configurations: configuration)
            
            let sampleData = BookItem(
                id: 1,
                title: "To Kill a Mockingbird",
                author: "Harper Lee",
                details: "A timeless classic addressing racism and justice through the eyes of young Scout Finch as her father defends a Black man wrongly accused in the Deep South.",
                genre: "Classic Literature",
                yearPublished: "1960",
                coverImage: "mockingbird",
                isFavorite: false
            )
            
            return DetailView(book: sampleData)
                .modelContainer(container)
        } catch {
            fatalError("Could not load preview data: \(error.localizedDescription)")
        }
    }
}


//
//  FavoritesView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/20/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    // favorite books
    @Query(filter: #Predicate<BookItem> { $0.isFavorite })
    private var favorites: [BookItem]
    @State private var path = [BookItem]()
    
    // remove duplicate books from favorites for display
    private var uniqueFavorites: [BookItem] {
            var seen = Set<String>()
            var result: [BookItem] = []
            
            for book in favorites {
                // Prefer Open Library key; fall back to title+author combo
                let key = book.openLibraryKey ??
                    "\(book.title.lowercased())|\(book.author.lowercased())"
                
                if !seen.contains(key) {
                    seen.insert(key)
                    result.append(book)
                }
            }
            return result
        }
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea(edges: .all)
                
                List {
                    ForEach(uniqueFavorites) { item in
                        NavigationLink(value: item) {
                            HStack {
                                coverView(for: item)
                                    .frame(width: 60, height: 80)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .fontWeight(.bold)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 5)
                                        .foregroundStyle(Color("PrimaryBlue"))
                                    
                                    Text(item.author)
                                        .font(.subheadline)
                                        .foregroundStyle(Color("PrimaryBlue"))
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 5)
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(favorites.isEmpty ? "" : "Favorites")
                .navigationDestination(for: BookItem.self) { item in
                    DetailView(book: item)
                }
                .overlay {
                    if favorites.isEmpty {
                        CustomContentUnavailableView(
                            icon: "heart.slash",
                            title: "No Favorites",
                            description: "You haven't favorited any Books yet."
                        )
                    }
                }
            }
        }
        // run deduplication once the view appears
        .task {
                dedupeBooks()
            }
    }
    
    // MARK: cover view
    @ViewBuilder
    private func coverView(for item: BookItem) -> some View {
        if let urlString = item.coverURL,
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
                    fallbackCover(for: item)
                @unknown default:
                    fallbackCover(for: item)
                }
            }
        } else {
            fallbackCover(for: item)
        }
    }
    
    // Fallback cover when remote image is missing
    @ViewBuilder
    private func fallbackCover(for item: BookItem) -> some View {
        if !item.coverImage.isEmpty {
            Image(item.coverImage)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray.opacity(0.2)
        }
    }
    
    // MARK: remove duplication
    
    @MainActor
    private func dedupeBooks() {
        do {
            let descriptor = FetchDescriptor<BookItem>()
            let allBooks = try context.fetch(descriptor)
            
            var seen = [String: BookItem]()   // key (first book we keep)
            
            for book in allBooks {
                // Prefer Open Library key, fall back to title+author
                let key = book.openLibraryKey ??
                    "\(book.title.lowercased())|\(book.author.lowercased())"
                
                if let existing = seen[key] {
                    // Merge favorite flag so we don't lose favorites
                    if book.isFavorite && !existing.isFavorite {
                        existing.isFavorite = true
                    }
                    // Delete the duplicate
                    context.delete(book)
                } else {
                    seen[key] = book
                }
            }
            
            try context.save()
        } catch {
            print("Error deduping books:", error)
        }
    }
}

// MARK: - preview

extension BookItem {
    @MainActor
    static var favoritesPreview: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: BookItem.self, configurations: configuration)
        
        // Favorite book samples
        container.mainContext.insert(BookItem(
            id: 1,
            title: "The Hobbit",
            author: "J.R.R. Tolkien",
            details: "Bilbo’s adventure through Middle-earth.",
            genre: "Fantasy",
            yearPublished: "1937",
            coverImage: "hobbit",
            isFavorite: true
        ))

        container.mainContext.insert(BookItem(
            id: 2,
            title: "1984",
            author: "George Orwell",
            details: "A chilling dystopian surveillance society.",
            genre: "Dystopian",
            yearPublished: "1949",
            coverImage: "1984",
            isFavorite: true
        ))

        return container
    }
}


#Preview {
    FavoritesView()
        .modelContainer(BookItem.favoritesPreview)
}

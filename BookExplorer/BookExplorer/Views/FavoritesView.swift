//
//  FavoritesView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/20/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(filter: #Predicate<BookItem> { $0.isFavorite }) // This fetches Catalog items where isFavorite is set to true
    private var favorites: [BookItem]
    @State private var path = [BookItem]()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea(edges: .all)
                
                List {
                    ForEach(favorites) { item in
                        NavigationLink(value: item) {
                            HStack {
                                Image(item.coverImage)
                                    .resizable()
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
                .navigationDestination(for: BookItem.self){ item in
                    DetailView(book: item)
                }
                .overlay {
                    if favorites.isEmpty {
                        CustomContentUnavailableView(icon: "heart.slash", title: "No Favorites", description: "You haven't favorited any Books yet.")
                    }
                }
            }
        }
    }
}

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

//
//  ContentView.swift
//  NationalParksCatalog
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [BookItem]
    
    var body: some View {
        TabView {
            Tab("Catalog", systemImage: "square.grid.2x2"){
                CatalogGridView()
                    .task{
                        if items.isEmpty { // checks if items is empty to seed
                            seed()
                        }
                    }
            }
            
            Tab("Favorites", systemImage: "heart.fill"){
                FavoritesView()
            }
            
        }
            
    }

    @MainActor
    private func seed() { // seeds data into modelContext from catalogData
        for s in catalogData {
            modelContext.insert(BookItem(id: s.id, title: s.title, author: s.author, details: s.details, genre: s.genre, yearPublished: s.yearPublished, coverImage: s.coverImage, isFavorite: s.isFavorite))
        }
        try! modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BookItem.self, inMemory: true)
}

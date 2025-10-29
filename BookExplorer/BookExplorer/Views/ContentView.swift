//
//  ContentView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [BookItem]
    
    // Starts selected tab on catalog screen
    @State private var selectedTab: AppTab = .catalog
    // Ensures data is only seeded once
    @State private var hasSeeded = false
    
    var body: some View {
        // Custom tab bar at bottom
        ZStack {
            Group {
                switch selectedTab {
                case .catalog:
                    CatalogGridView()
                case .favorites:
                    FavoritesView()
                case .stats:
                    StatsView()
                }
            }
            // Fade transition when selecting new tab
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
        // Place custom tab bar at bottom
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        // Seeds the sample data when view appears (only once)
        .task {
            guard !hasSeeded else { return }
            if items.isEmpty {
                seed()
            }
            hasSeeded = true
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }

    @MainActor
    private func seed() { // seeds placeholder data into modelContext from catalogData
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

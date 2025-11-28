//
//  ContentView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Starts selected tab on catalog screen
    @EnvironmentObject var tabSelection: TabSelection
    
    var body: some View {
        // Custom tab bar at bottom
        ZStack {
            Group {
                switch tabSelection.selectedTab {
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
            .animation(.easeInOut(duration: 0.2), value: tabSelection.selectedTab)
        }
        // Place custom tab bar at bottom
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $tabSelection.selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BookItem.self, inMemory: true)
}


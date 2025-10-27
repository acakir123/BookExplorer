//
//  TabView.swift
//  BookExplorer
//
//  Created by Aaron Kisitu on 10/27/25.
//

import SwiftUI

// MARK: Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 28) {
            TabButton(icon: "square.grid.2x2.fill", title: "Catalog", isSelected: selectedTab == .catalog) {
                selectedTab = .catalog
            }
            TabButton(icon: "heart.fill", title: "Favorites", isSelected: selectedTab == .favorites) {
                selectedTab = .favorites
            }
            TabButton(icon: "chart.xyaxis.line", title: "Stats", isSelected: selectedTab == .stats) {
                selectedTab = .stats
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }
}

// MARK: Tab Button
struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.accentColor : .primary)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(title))
    }
}

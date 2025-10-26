//
//  BookExplorerApp.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 10/25/25.
//

import SwiftUI
import SwiftData

@main
struct BookExplorerApp: App {
    // This is for better contrast with our search bar and custom background
    init() {
            let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            textFieldAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            textFieldAppearance.layer.cornerRadius = 10
            textFieldAppearance.clipsToBounds = true
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for : BookItem.self)
        }
    }
}

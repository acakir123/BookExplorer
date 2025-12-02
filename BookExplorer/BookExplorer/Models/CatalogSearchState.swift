//
//  CatalogSearchState.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 12/1/25.
//

import SwiftUI

// Shared search date for the catalog tab
final class CatalogSearchState: ObservableObject {

    @AppStorage("catalogSearchText") private var storedSearchText: String = ""

    // whenever these search text changes, update the persistent storage
    @Published var searchText: String {
        didSet {
            storedSearchText = searchText
        }
    }

    init() {
        // Initialize searchText from stored value
        self.searchText = UserDefaults.standard.string(forKey: "catalogSearchText") ?? ""
    }
}

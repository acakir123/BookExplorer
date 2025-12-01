//
//  CatalogSearchState.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 12/1/25.
//

import SwiftUI

final class CatalogSearchState: ObservableObject {

    @AppStorage("catalogSearchText") private var storedSearchText: String = ""

    @Published var searchText: String {
        didSet {
            storedSearchText = searchText        // keep it persisted
        }
    }

    init() {
        // Initialize searchText from stored value
        self.searchText = UserDefaults.standard.string(forKey: "catalogSearchText") ?? ""
    }
}

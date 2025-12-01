//
//  CatalogSearchState.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 12/1/25.
//

import SwiftUI

final class CatalogSearchState: ObservableObject {

    @AppStorage("catalogSearchText") private var storedSearchText: String = ""

    @Published var searchText: String

    init() {
        let initial = UserDefaults.standard.string(forKey: "catalogSearchText") ?? ""
        self.searchText = initial
    }

    func update(_ newValue: String) {
        searchText = newValue
        storedSearchText = newValue
    }
}

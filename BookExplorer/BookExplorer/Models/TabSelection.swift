//
//  TabSelection.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 11/28/25.
//

import SwiftUI

// Used for custom tab bar
class TabSelection: ObservableObject {
    @Published var selectedTab: AppTab = .catalog
}


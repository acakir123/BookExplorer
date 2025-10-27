//
//  CustomContentUnavailableView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/20/25.
//

import SwiftUI

struct CustomContentUnavailableView: View {
    var icon: String
    var title: String
    var description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color("PrimaryBlue"))
            
            Text(title)
                .font(.title)
                .foregroundStyle(Color("PrimaryBlue"))
        } description: {
            Text(description)
        }
    }
}

#Preview {
    CustomContentUnavailableView(icon: "heart.slash", title: "No Favorites", description: "You haven't added any favorites yet.")
}

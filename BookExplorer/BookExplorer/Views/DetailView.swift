//
//  DetailView.swift
//  NationalParksCatalog
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var park: BookItem
    
    var body: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea(edges: .all)
            ScrollView {
                
                VStack (){
                    Image(park.coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 300)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(park.title)
                        .font(.title)
                        .foregroundStyle(Color("PrimaryBlue"))
                        .padding()
                    
                    HStack {
                        Spacer()
                        
                        Text(park.author)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            
                        
                        Spacer()
                        
                        Text(park.genre)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(park.yearPublished)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(park.details)
                        .font(.body)
                        .padding()
                    
                    
                    Button { // Search similar button
                        dismiss() // Currently only dismisses but when we integrate the API it'll search for similar books and take the user to CatalogGridView
                    } label: {
                        Text("Search Similar")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .background(Capsule(style: .continuous))
                    .foregroundStyle(Color("SecondaryBlue"))
                    .padding(.horizontal)
                    
                    
                    
                    Spacer()
                }
                .navigationBarBackButtonHidden(true) // To hide the default back button
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { // Custom back button
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left.circle")
                                .font(.title)
                                .foregroundStyle(Color("SecondaryBlue"))
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { // Favorite button
                            park.isFavorite.toggle()
                        } label: {
                            Image(systemName: park.isFavorite ? "heart.fill" : "heart")
                                .font(.title)
                                .foregroundStyle(Color("SecondaryBlue"))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: BookItem.self, configurations: configuration)
                
            let sampleData = BookItem(
                id: 1,
                title: "To Kill a Mockingbird",
                author: "Harper Lee",
                details: "A timeless classic addressing racism and justice through the eyes of young Scout Finch as her father defends a Black man wrongly accused in the Deep South.",
                genre: "Classic Literature",
                yearPublished: "1960",
                coverImage: "mockingbird",
                isFavorite: false
            )
            
            return DetailView(park: sampleData)
                .modelContainer(container)
        } catch {
            fatalError("Could not load preview data: \(error.localizedDescription)")
        }
    }
}

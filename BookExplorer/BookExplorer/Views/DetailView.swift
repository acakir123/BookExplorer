//
//  DetailView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var book: BookItem
    
    var body: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea(edges: .all)
            ScrollView {
                
                VStack (){
                    Image(book.coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 300)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(book.title)
                        .font(.title)
                        .foregroundStyle(Color("PrimaryBlue"))
                        .padding()
                    
                    HStack {
                        Spacer()
                        
                        Text(book.author)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            
                        
                        Spacer()
                        
                        Text(book.genre)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(book.yearPublished)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(book.details)
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
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("SecondaryBlue"))
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { // Favorite button
                            book.isFavorite.toggle()
                        } label: {
                            Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                .font(.title)
                                .fontWeight(.semibold)
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
            
            return DetailView(book: sampleData)
                .modelContainer(container)
        } catch {
            fatalError("Could not load preview data: \(error.localizedDescription)")
        }
    }
}

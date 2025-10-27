//
//  CatalogGridView.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct CatalogGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [BookItem]
    
    @State private var path = [BookItem]()
    
    // State variable for searching books
    @State private var searchText = ""
    
    private var filteredBooks: [BookItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return books // If empty return the normal list of books
        }
        return books.filter { // filter books using title and subtitle
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack (path: $path){
            ZStack{
                Color("BackgroundColor")
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    LazyVGrid(columns: layout){
                        ForEach(filteredBooks) { book in
                            NavigationLink(value: book){
                                VStack (alignment: .leading){
                                    
                                    Image(book.coverImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 165, height: 200)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    
                                    Text("\(book.title)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.vertical, 3)
                                        .foregroundStyle(Color("PrimaryBlue"))
                                    
                                    HStack {
                                                                                
                                        Text("\(book.author)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                book.isFavorite.toggle()
                                            }
                                        } label: {
                                            Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                                .foregroundStyle(Color("PrimaryBlue"))
                                        }
                                        .padding(.horizontal)
                                        
                                    }
                                    .padding(.bottom, 1)
                                    
                                    HStack {
                                        Text(book.genre)
                                            .font(.caption)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
                                        
                                        Text(book.yearPublished)
                                            .font(.caption)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                    }
                                    
                                    
                                }
                                .padding(8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                .aspectRatio(contentMode: .fit)
                            }
                            .foregroundStyle(.primary)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                }
                // Extra scroll space so bottom cards are visible above tab bar
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 92) // tab bar height + a little extra
                }
                .navigationTitle("Featured Books")
                .navigationDestination(for: BookItem.self) { book in
                    DetailView(book: book)
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Books") // For search bar
    }
}

#Preview {
    CatalogGridView()
        .modelContainer(BookItem.preview)
}

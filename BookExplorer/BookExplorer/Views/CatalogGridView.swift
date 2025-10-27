//
//  CatalogGridView.swift
//  NationalParksCatalog
//
//  Created by Ahmet Cakir on 9/19/25.
//

import SwiftUI
import SwiftData

struct CatalogGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var parks: [BookItem]
    
    @State private var path = [BookItem]()
    
    // State variable for searching parks
    @State private var searchText = ""
    
    private var filteredParks: [BookItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return parks // If empty return the normal list of parks
        }
        return parks.filter { // filter parks using title and subtitle
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
                        ForEach(filteredParks) { park in
                            NavigationLink(value: park){
                                VStack (alignment: .leading){
                                    
                                    Image(park.coverImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 165, height: 200)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    
                                    Text("\(park.title)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.vertical, 3)
                                        .foregroundStyle(Color("PrimaryBlue"))
                                    
                                    HStack {
                                        
                                        //Spacer()
                                        
                                        Text("\(park.author)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                park.isFavorite.toggle()
                                            }
                                        } label: {
                                            Image(systemName: park.isFavorite ? "heart.fill" : "heart")
                                                .foregroundStyle(Color("PrimaryBlue"))
                                        }
                                        .padding(.horizontal)
                                        
                                    }
                                    .padding(.bottom, 1)
                                    
                                    HStack {
                                        Text(park.genre)
                                            .font(.caption)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
                                        
                                        Text(park.yearPublished)
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
                .navigationTitle("Featured Books")
                .navigationDestination(for: BookItem.self) { park in
                    DetailView(park: park)
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

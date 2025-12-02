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
    
    // Only show books that belong to the current catalog feed
    @Query(filter: #Predicate<BookItem> { $0.inCatalogFeed })
    private var books: [BookItem]
    
    @State private var path = [BookItem]()
    
    // Environment object for searching books
    @EnvironmentObject var catalogSearchState: CatalogSearchState
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var isRefreshing = false
    
    @State private var scrollResetID = UUID()
        
    private var filteredBooks: [BookItem] {
        books
    }
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack (path: $path) {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    LazyVGrid(columns: layout) {
                        ForEach(filteredBooks) { book in
                            NavigationLink(value: book) {
                                VStack(alignment: .leading) {
                                    
                                    // Cover image: remote if available, fallback to asset
                                    bookCoverView(for: book)
                                        .frame(width: 165, height: 200)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    HStack {
                                        Text(book.title)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.vertical, 3)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
                                        
                                        Text(book.yearPublished)
                                            .font(.subheadline)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                    }
                                    
                                    HStack {
                                        Text(book.author)
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
                                    }
                                    .padding(.bottom, 1)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Text(book.genre)
                                            .font(.caption)
                                            .foregroundStyle(Color("PrimaryBlue"))
                                        
                                        Spacer()
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
                .id(scrollResetID)
                // Extra scroll space so bottom cards are visible above tab bar
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 92) // tab bar height + a little extra
                }
                .navigationTitle("Featured Books")
                .navigationDestination(for: BookItem.self) { book in
                    DetailView(book: book)
                }
                
                // Loading overlay
                if isLoading {
                    ProgressView("Loading books...")
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // Error overlay
                if let errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(8)
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // ⬇️ reset scroll position
                        scrollResetID = UUID()
                        
                        Task {
                            isRefreshing = true
                            catalogSearchState.searchText = ""
                            await loadTrending()
                            isRefreshing = false
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Color("PrimaryBlue"))
                            .fontWeight(.medium)
                    }
                    .accessibilityLabel("Refresh Trending Books")
                }
            }
        }
        .onAppear {
            if books.isEmpty && catalogSearchState.searchText.isEmpty {
                Task { await loadTrending() }
            }
        }
        .searchable(
            text: $catalogSearchState.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search Books"
        )
        .onSubmit(of: .search) {
            Task {
                await performSearch()
            }
        }
        .onChange(of: catalogSearchState.searchText) { newValue in
            guard !isRefreshing else { return }
            
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                // When the user clears the search, go back to trending
                Task {
                    await loadTrending()
                }
            }
        }
    }
    
    // MARK: - Cover View
    
    @ViewBuilder
    private func bookCoverView(for book: BookItem) -> some View {
        if let urlString = book.coverURL,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackCover(for: book)
                @unknown default:
                    fallbackCover(for: book)
                }
            }
        } else {
            fallbackCover(for: book)
        }
    }
    
    @ViewBuilder
    private func fallbackCover(for book: BookItem) -> some View {
        if !book.coverImage.isEmpty {
            Image(book.coverImage)
                .resizable()
                .scaledToFill()
        } else {
            // Simple colored placeholder if we have no local asset
            Color.gray.opacity(0.2)
        }
    }
    
    // MARK: - Networking
    
    private func loadTrending() async {
        await loadBooks { api in
            try await api.fetchTrending(limit: 10)
        }
    }
    
    private func performSearch() async {
        let trimmed = catalogSearchState.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            await loadTrending()
            return
        }
        
        await loadBooks { api in
            try await api.searchBooks(query: trimmed, limit: 10)
        }
    }
    
    private func loadBooks(
        _ block: (OpenLibraryAPI) async throws -> [OpenLibraryDoc]
    ) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let docs = try await block(OpenLibraryAPI.shared)
            try await syncBooksFromOpenLibrary(docs, in: modelContext)
        } catch {
            await MainActor.run {
                errorMessage = "Could not load books. Please try again."
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

#Preview {
    CatalogGridView()
        .environmentObject(CatalogSearchState())
        .modelContainer(BookItem.preview)
}


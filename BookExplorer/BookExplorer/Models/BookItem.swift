//
//  Item.swift
//  NationalParksCatalog
//
//  Created by Ahmet Cakir on 9/19/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class BookItem {
    var id: Int
        var title: String
        var author: String
        var details: String
        var genre: String
        var yearPublished: String
        var coverImage: String // String for now will probably be URL when fetching with API
        var isFavorite: Bool = false
        
        init(id: Int,
             title: String,
             author: String,
             details: String,
             genre: String,
             yearPublished: String,
             coverImage: String,
             isFavorite: Bool = false) {
            
            self.id = id
            self.title = title
            self.author = author
            self.details = details
            self.genre = genre
            self.yearPublished = yearPublished
            self.coverImage = coverImage
            self.isFavorite = isFavorite
        }
}

extension BookItem { // Extension to help with previews
    @MainActor
    
    static var preview: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: BookItem.self, configurations: configuration)
        
        container.mainContext.insert(BookItem(
                    id: 1,
                    title: "To Kill a Mockingbird",
                    author: "Harper Lee",
                    details: "A timeless classic addressing racism and justice through the eyes of young Scout Finch as her father defends a Black man wrongly accused in the Deep South.",
                    genre: "Classic Literature",
                    yearPublished: "1960",
                    coverImage: "mockingbird",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 2,
                    title: "1984",
                    author: "George Orwell",
                    details: "A dystopian novel exploring the dangers of totalitarianism as Winston Smith struggles against constant surveillance and government control.",
                    genre: "Dystopian",
                    yearPublished: "1949",
                    coverImage: "1984",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 3,
                    title: "The Great Gatsby",
                    author: "F. Scott Fitzgerald",
                    details: "Jay Gatsby’s obsessive pursuit of Daisy Buchanan highlights themes of love, wealth, and the American Dream in the Roaring Twenties.",
                    genre: "Classic Literature",
                    yearPublished: "1925",
                    coverImage: "gatsby",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 4,
                    title: "Pride and Prejudice",
                    author: "Jane Austen",
                    details: "A romantic comedy of manners centered around Elizabeth Bennet as she navigates love, class expectations, and first impressions.",
                    genre: "Romance",
                    yearPublished: "1813",
                    coverImage: "pride",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 5,
                    title: "The Hobbit",
                    author: "J.R.R. Tolkien",
                    details: "Bilbo Baggins embarks on an unexpected adventure involving dwarves, a dragon, and a mysterious ring that will change Middle-earth forever.",
                    genre: "Fantasy",
                    yearPublished: "1937",
                    coverImage: "hobbit",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 6,
                    title: "The Catcher in the Rye",
                    author: "J.D. Salinger",
                    details: "Holden Caulfield recounts his teenage struggles with identity, alienation, and loss while wandering New York City.",
                    genre: "Fiction / Coming-of-Age",
                    yearPublished: "1951",
                    coverImage: "rye",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 7,
                    title: "Moby-Dick",
                    author: "Herman Melville",
                    details: "Captain Ahab’s obsessive quest for revenge against the white whale explores fate, obsession, and humanity’s relationship with nature.",
                    genre: "Adventure",
                    yearPublished: "1851",
                    coverImage: "moby_dick",
                    isFavorite: false
                ))

                container.mainContext.insert(BookItem(
                    id: 8,
                    title: "Harry Potter and the Sorcerer’s Stone",
                    author: "J.K. Rowling",
                    details: "Harry discovers he is a wizard and begins his magical education at Hogwarts, making friends and facing dark challenges.",
                    genre: "Fantasy",
                    yearPublished: "1997",
                    coverImage: "harry_potter",
                    isFavorite: false
                ))
        
        return container
    }
}

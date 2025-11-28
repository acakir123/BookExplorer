//
//  BookStoreSync.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 11/28/25.
//

import Foundation
import SwiftData

/// Applies a set of Open Library docs to the SwiftData store
/// - Keeps favorites (isFavorite == true) intact
/// - Marks all existing books as not in current catalog feed
/// - Upserts docs & marks them as in the current feed
@MainActor
func syncBooksFromOpenLibrary(_ docs: [OpenLibraryDoc],
                              in context: ModelContext) throws {
    let fetchDescriptor = FetchDescriptor<BookItem>()
    let existing = try context.fetch(fetchDescriptor)
    
    // First mark all books as not in the current catalog feed
    for book in existing {
        book.inCatalogFeed = false
    }
    
    // For fast lookup by Open Library key
    var existingByKey: [String: BookItem] = [:]
    for book in existing {
        if let key = book.openLibraryKey {
            existingByKey[key] = book
        }
    }
    
    // Upsert API docs
    for (index, doc) in docs.enumerated() {
        let key = doc.key
        
        if let existingBook = existingByKey[key] {
            // Update fields, keep favorite flag as-is
            existingBook.title = doc.title ?? existingBook.title
            existingBook.author = doc.mainAuthor
            existingBook.genre = doc.mainGenre
            existingBook.details = doc.descriptionText
            existingBook.yearPublished = doc.yearString
            existingBook.coverURL = doc.coverURLString
            existingBook.inCatalogFeed = true
        } else {
            // New book from API
            let newBook = BookItem(
                id: index, // local numeric id; not the OL key
                title: doc.title ?? "Unknown Title",
                author: doc.mainAuthor,
                details: doc.descriptionText,
                genre: doc.mainGenre,
                yearPublished: doc.yearString,
                coverImage: "",          // we will use coverURL instead
                isFavorite: false,
                openLibraryKey: key,
                coverURL: doc.coverURLString,
                inCatalogFeed: true
            )
            context.insert(newBook)
        }
    }
    
    try context.save()
}

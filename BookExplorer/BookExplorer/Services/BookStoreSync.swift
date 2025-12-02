//
//  BookStoreSync.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 11/28/25.
//

import Foundation
import SwiftData

/// Applies a set of Open Library docs to the SwiftData store
/// - Keeps favorites (isFavorite == true) intact, so favorites survive new API loads.
/// - Uses openLibraryKey (the work key) to find matches.
/// - Updates existing books in-place if a matching key is found.
/// - Marks all existing books as not in current catalog feed
/// - Inserts new BookItems when no existing match is found.
@MainActor
func syncBooksFromOpenLibrary(_ docs: [OpenLibraryDoc],
                              in context: ModelContext) throws {
    // fetch all existing BookItem objects from the store
    let fetchDescriptor = FetchDescriptor<BookItem>()
    let existing = try context.fetch(fetchDescriptor)
    
    // 1, Mark all books as not in the current catalog feed
    // (treats the incoming docs as the new "current feed".)
    for book in existing {
        book.inCatalogFeed = false
    }
    
    // 2, Create fast lookup table for existing books by Open Library key
    var existingByKey: [String: BookItem] = [:]
    for book in existing {
        if let key = book.openLibraryKey {
            existingByKey[key] = book
        }
    }
    
    // 3. Upsert API docs:
    // (If a matching key already exists update fields, otherwise create a new BookItem)
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
            // Insert a new book for this API doc
            let newBook = BookItem(
                id: doc.key.hashValue,
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
    
    // Persist all changes to store
    try context.save()
}

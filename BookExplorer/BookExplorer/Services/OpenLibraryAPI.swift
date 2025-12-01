//
//  OpenLibraryAPI.swift
//  BookExplorer
//
//  Created by Ahmet Cakir on 11/28/25.
//

import Foundation

// MARK: - API Models

struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryDoc]
}

struct OpenLibraryDoc: Decodable {
    let key: String                      // Work key, e.g. "/works/OL27448W"
    let title: String?
    let author_name: [String]?
    let first_publish_year: Int?
    let cover_i: Int?
    let subject: [String]?
}

struct TrendingResponse: Codable {
    let works: [TrendingBook]
}

struct TrendingBook: Codable { // To store trending books
    let key: String
    let title: String
    let authors: [Author]?
    let first_publish_year: Int?
    let subject: [String]?
    let cover_i: Int?
    
    struct Author: Codable {
        let name: String?
    }
}

extension OpenLibraryDoc {
    /// Large cover URL using Open Library covers API
    /// e.g. https://covers.openlibrary.org/b/id/258027-L.jpg
    var coverURLString: String? {
        guard let id = cover_i else { return nil }
        return "https://covers.openlibrary.org/b/id/\(id)-L.jpg"
    }
    
    /// First author or placeholder
    var mainAuthor: String {
        author_name?.first ?? "Unknown Author"
    }
    
    /// Use the first subject as a “genre”
    var mainGenre: String {
        subject?.first ?? "Unknown Genre"
    }
    
    /// Published year as string
    var yearString: String {
        if let y = first_publish_year {
            return String(y)
        } else {
            return "N/A"
        }
    }
    
    /// Simple details text based on subjects
    var descriptionText: String {
        if let subjects = subject, !subjects.isEmpty {
            let top = subjects.prefix(6).joined(separator: ", ")
            return "Subjects: \(top)"
        } else {
            return "No additional details available."
        }
    }
}

// MARK: - API Client

final class OpenLibraryAPI {
    static let shared = OpenLibraryAPI()
    
    private let baseURL = URL(string: "https://openlibrary.org")!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// "Trending" style feed using search.json & sort=random
    /// (10 random books as a stand-in for trending)
    func fetchTrending(limit: Int = 10) async throws -> [OpenLibraryDoc] {
        let url = baseURL.appendingPathComponent("/trending/daily.json")
        var request = URLRequest(url: url)
        request.setValue(
            "BookExplorer/1.0 (your-email@example.com)",
            forHTTPHeaderField: "User-Agent"
        )
        
        let (data, _) = try await URLSession.shared.data(for: request)

        let trending = try JSONDecoder().decode(TrendingResponse.self, from: data)
        
        // Map TrendingBook → OpenLibraryDoc
        let mapped: [OpenLibraryDoc] = trending.works.map { work in
            OpenLibraryDoc(
                key: work.key,
                title: work.title,
                author_name: work.authors?.compactMap { $0.name } ?? [],
                first_publish_year: work.first_publish_year,
                cover_i: work.cover_i,
                subject: work.subject ?? []
            )
        }
        
        // Shuffle and limit
        return Array(mapped.shuffled().prefix(limit))
    }
    
    /// Search by title, limited to 10 results
    func searchBooks(query: String, limit: Int = 10) async throws -> [OpenLibraryDoc] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/search.json"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "title", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(
                name: "fields",
                value: "key,title,author_name,first_publish_year,subject,cover_i"
            )
        ]
        
        return try await performRequest(components: components)
    }
    
    /// "Similar" books using either genre or title as the search query
    func searchSimilarBooks(title: String, genre: String?, limit: Int = 10) async throws -> [OpenLibraryDoc] {
        let baseQuery = (genre?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? genre!
        : title
        
        var components = URLComponents(url: baseURL.appendingPathComponent("/search.json"),
                                       resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: baseQuery),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(
                name: "fields",
                value: "key,title,author_name,first_publish_year,subject,cover_i"
            )
        ]
        
        return try await performRequest(components: components)
    }
    
    // MARK: - Internal
    
    private func performRequest(components: URLComponents) async throws -> [OpenLibraryDoc] {
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        // Good practice per Open Library docs: identify your app & contact
        request.setValue(
            "BookExplorer/1.0 (your-email@example.com)",
            forHTTPHeaderField: "User-Agent"
        )
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenLibrarySearchResponse.self, from: data)
        return result.docs
    }
}

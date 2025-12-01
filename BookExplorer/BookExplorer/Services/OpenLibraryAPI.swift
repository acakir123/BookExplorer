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
    var subject: [String]?
}

struct TrendingResponse: Decodable {
    let works: [OpenLibraryDoc]
}

struct WorkDetail: Decodable {
    let subjects: [String]?
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
    
    private func fetchSubjects(for workKey: String) async throws -> [String] { // To get subjects for trending books
        let cleanKey = workKey.hasPrefix("/") ? String(workKey.dropFirst()) : workKey
        let url = baseURL.appendingPathComponent("\(cleanKey).json")

        var request = URLRequest(url: url)
        request.setValue(
            "BookExplorer/1.0 (your-email@example.com)",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, _) = try await URLSession.shared.data(for: request)
        let detail = try JSONDecoder().decode(WorkDetail.self, from: data)
        // If the API doesn’t provide subjects, just return an empty array
        return detail.subjects ?? []
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
        let response = try JSONDecoder().decode(TrendingResponse.self, from: data)

        var docs = Array(response.works.prefix(limit))

        for i in docs.indices { // populating subject here
            if let subjects = try? await fetchSubjects(for: docs[i].key),
               !subjects.isEmpty {
                docs[i].subject = subjects
            }
        }

        return docs
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

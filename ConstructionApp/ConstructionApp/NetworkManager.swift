//
//  NetworkManager.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 1.03.2026.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetcSampleData() async throws -> String {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = String(decoding: data, as: UTF8.self)
        return result
    }
}

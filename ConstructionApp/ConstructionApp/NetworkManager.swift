//
//  NetworkManager.swift
//  ConstructionApp
//

import Foundation

// 1. İNTERNETTEN GELECEK VERİNİN KALIBI (MODEL)
// 'Codable' sayesinde JSON verisi otomatik olarak bu yapıya dönüşür.
struct MarketMaterial: Identifiable, Codable {
    var id: String { name } // Her malzemenin adı benzersiz olduğu için ID olarak kullanıyoruz
    let name: String
    let unit: String
    let price: Double
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // 2. CANLI VERİ ÇEKME FONKSİYONU
    func fetchMarketPrices() async throws -> [MarketMaterial] {
        // Gerçek bir API'ye bağlanıyormuşuz gibi 1.5 saniye internet gecikmesi simüle ediyoruz
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Sunucudan (API) gelen evrensel JSON veri formatı
        let jsonString = """
        [
            {"name": "Çimento (Torba)", "unit": "Adet", "price": 145.50},
            {"name": "Hazır Beton (C30)", "unit": "m3", "price": 2450.00},
            {"name": "İnşaat Demiri", "unit": "Ton", "price": 23500.00},
            {"name": "Tuğla", "unit": "Adet", "price": 9.50},
            {"name": "Kum", "unit": "Ton", "price": 450.00},
            {"name": "Boya (İç Cephe)", "unit": "Kova", "price": 850.00}
        ]
        """
        
        // Metni Data (veri) formatına çeviriyoruz
        guard let data = jsonString.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        // 3. ÇEVİRMEN (JSONDecoder): JSON datasını al, 'MarketMaterial' dizisine çevir
        let materials = try JSONDecoder().decode([MarketMaterial].self, from: data)
        return materials
    }
}

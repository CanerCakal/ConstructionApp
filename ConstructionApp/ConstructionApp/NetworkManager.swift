//
//  NetworkManager.swift
//  ConstructionApp
//

import Foundation

// API'den gelecek JSON formatı
struct CurrencyResponse: Codable {
    let base_code: String
    let rates: [String: Double]
}

// Ekranda göstereceğimiz İnşaat Malzemesi Modeli
struct MarketMaterial: Identifiable {
    let id = UUID()
    let name: String
    let unit: String
    let basePriceUSD: Double // Malzemenin dünyadaki sabit dolar fiyatı
    var currentPriceTRY: Double = 0.0 // Canlı kurla hesaplanacak TL fiyatı
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Hem canlı kuru hem de hesaplanmış malzemeleri aynı anda döndüren fonksiyon
    func fetchLiveMaterialPrices() async throws -> (Double, [MarketMaterial]) {
        
        // 1. Canlı Döviz API'sine bağlan
        guard let url = URL(string: "https://open.er-api.com/v6/latest/USD") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedData = try JSONDecoder().decode(CurrencyResponse.self, from: data)
        
        // 2. Canlı Dolar / TL (TRY) kurunu al
        guard let tryRate = decodedData.rates["TRY"] else {
            throw URLError(.cannotParseResponse)
        }
        
        // 3. İnşaat malzemelerinin Dolar (USD) bazındaki ortalama fiyatları
        var materials = [
            MarketMaterial(name: "Çimento (Torba)", unit: "Adet", basePriceUSD: 4.5),
            MarketMaterial(name: "Hazır Beton (C30)", unit: "m3", basePriceUSD: 75.0),
            MarketMaterial(name: "İnşaat Demiri", unit: "Ton", basePriceUSD: 720.0),
            MarketMaterial(name: "Tuğla", unit: "Adet", basePriceUSD: 0.30),
            MarketMaterial(name: "Kum", unit: "Ton", basePriceUSD: 14.0),
            MarketMaterial(name: "Boya (İç Cephe)", unit: "Kova", basePriceUSD: 26.0)
        ]
        
        // 4. SİHİRLİ DOKUNUŞ: Her malzemenin Dolar fiyatını canlı TL kuruyla çarp!
        for i in 0..<materials.count {
            materials[i].currentPriceTRY = materials[i].basePriceUSD * tryRate
        }
        
        // Hem o anki güncel kuru hem de hesaplanmış listeyi geri gönder
        return (tryRate, materials)
    }
}

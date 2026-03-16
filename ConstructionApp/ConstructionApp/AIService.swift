//
//  AIService.swift
//  ConstructionApp
//

import Foundation

class AIService {
    static let shared = AIService()
    private init() {}
    
    // Artık şifreyi buraya yazmıyoruz, güvenli Secrets dosyasından çekiyoruz!
    private let apiKey = Secrets.geminiAPIKey
    
    func analyzeProjectWithAI(project: Project) async throws -> String {
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let prompt = """
        Sen bir inşaat mühendisi asistanısın. Şu anki projemizin adı '\(project.name)'. Toplam alanı \(project.area) metrekare. Toplam maliyeti \(project.totalCost) TL. Projede \(project.materials.count) farklı malzeme kullanılıyor. Bu proje için profesyonel, yapıcı ve en fazla 3 cümlelik bir maliyet veya verimlilik analizi yapar mısın?
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // YENİ: HTTP Yanıtını kontrol et. Eğer 200 (Başarılı) değilse hatayı konsola yazdır!
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "Bilinmeyen API Hatası"
            print("🚨 GEMINI API HATASI: \(errorString)")
            return "Yapay zeka sunucusu hata döndürdü. Lütfen Xcode konsolunu kontrol et."
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let candidates = json["candidates"] as? [[String: Any]],
           let firstCandidate = candidates.first,
           let content = firstCandidate["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let firstPart = parts.first,
           let text = firstPart["text"] as? String {
            return text
        } else {
            return "Yapay zekadan beklenen formatta cevap alınamadı."
        }
    }
}

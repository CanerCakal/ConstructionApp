//
//  AIService.swift
//  ConstructionApp
//

import Foundation

class AIService {
    static let shared = AIService()
    private init() {}
    
    // BURAYA KENDİ API ANAHTARINI YAPIŞTIR
    private let apiKey = "AIzaSyCVioSWgcYB9qEwsO6W562gsIGHM8ZTudM"
    
    // İnternet işlemi zaman alacağı için 'async throws' kullanıyoruz
    func analyzeProjectWithAI(project: Project) async throws -> String {
        
        // 1. URL Hazırlığı (Gemini modeline bağlanıyoruz)
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // 2. Prompt (Yapay zekaya soracağımız soru) hazırlığı
        let prompt = """
        Sen bir inşaat mühendisi asistanısın. Şu anki projemizin adı '\(project.name)'. Toplam alanı \(project.area) metrekare. Toplam maliyeti \(project.totalCost) TL. Projede \(project.materials.count) farklı malzeme kullanılıyor. Bu proje için profesyonel, yapıcı ve en fazla 3 cümlelik bir maliyet veya verimlilik analizi yapar mısın?
        """
        
        // 3. İstek Gövdesi (Veriyi yapay zekanın anladığı JSON formatına çeviriyoruz)
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        
        // 4. İsteği Yapılandırma
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // 5. Bağlantıyı Kur ve Cevabı Al (Uygulama burada cevabı bekler)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // 6. Gelen JSON verisinin içinden sadece yapay zekanın yazdığı metni ayıklama (Parsing)
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

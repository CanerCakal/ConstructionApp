//
//  AIService.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 1.03.2026.
//

import Foundation

class AIService {
    static let shared = AIService()
    private init() {}
    
    func analyzeProject(project: Project) -> String {
        if project.totalCost > 1_000_000 {
            return "Bu proje yüksek maaliyetli gözüküyor. Alternatif malzeme araştırılabilir"
        } else if project.totalCost > 500_000 {
            return "Proje orta maaliyet aralığında."
        } else {
            return "Proje maaliyeti makul seviyede"
        }
    }
}

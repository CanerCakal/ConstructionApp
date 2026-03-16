//
//  ProjectDetailViewModel.swift
//  ConstructionApp
//

import Foundation
import SwiftData
import Combine

@MainActor
class ProjectDetailViewModel: ObservableObject {
    
    // View'da (Ekranda) değiştiği anda güncellenecek değişkenlerimiz
    @Published var availableMarketMaterials: [MarketMaterial] = []
    @Published var selectedMaterial: MarketMaterial?
    @Published var usageRate: String = ""
    @Published var errorMessage: String = ""
    @Published var aiAnalysesResult: String = "Projeye dair profesyonel bir maliyet ve verimlilik analizi almak için butona tıklayın."
    @Published var isAIAnalyzing: Bool = false
    
    // MARK: - İNTERNETTEN VERİ ÇEKME
    func loadMarketMaterials() async {
        do {
            let (_, materials) = try await NetworkManager.shared.fetchLiveMaterialPrices()
            self.availableMarketMaterials = materials
        } catch {
            self.errorMessage = "Malzeme kataloğu internetten çekilemedi."
        }
    }
    
    // MARK: - VERİTABANI İŞLEMLERİ
    func addMaterial(to project: Project, context: ModelContext) {
        errorMessage = ""
        
        guard let selected = selectedMaterial else {
            errorMessage = "Lütfen katalogdan bir malzeme seçin."
            return
        }
        
        let safeUsageStr = usageRate.replacingOccurrences(of: ",", with: ".")
        
        guard let usage = Double(safeUsageStr), usage > 0 else {
            errorMessage = "Geçerli bir kullanım miktarı girin."
            return
        }
        
        // Fiyat, İsim ve Birim artık doğrudan API'den gelen canlı veriler!
        let material = Material(name: selected.name, unit: selected.unit, userPerSquareMeter: usage, pricePerUnit: selected.currentPriceTRY)
        material.project = project
        project.materials.append(material)
        context.insert(material)
        
        do {
            try context.save()
            // İşlem bitince formu temizle
            selectedMaterial = nil
            usageRate = ""
        } catch {
            errorMessage = "Malzeme kaydedilirken hata oluştu."
        }
    }
    
    func deleteMaterial(_ material: Material, from project: Project, context: ModelContext) {
        if let index = project.materials.firstIndex(where: { $0.id == material.id }) {
            context.delete(material)
            project.materials.remove(at: index)
            try? context.save()
        }
    }
    
    func fetcAIAnalysis(for project: Project) {
        isAIAnalyzing = true
        aiAnalysesResult = "Yapay zeka projeyi analiz ediyor..."
        
        Task {
            do {
                let result = try await AIService.shared.analyzeProjectWithAI(project: project)
                await MainActor.run {
                    self.aiAnalysesResult = result
                    self.isAIAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.aiAnalysesResult = "Bağlantı Hatası: Analiz yapılamıyor"
                    self.isAIAnalyzing = false
                }
            }
        }
    }
    
}

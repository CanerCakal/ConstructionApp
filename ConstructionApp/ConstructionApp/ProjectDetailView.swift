//
//  ProjectDetailView.swift
//  ConstructionApp
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var project: Project
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    
    // Malzeme Ekleme Alanı Değişkenleri
    @State private var materialName: String = ""
    @State private var unit: String = ""
    @State private var usageRate: String = ""
    @State private var price: String = ""
    
    // Hata Mesajı Kontrolü
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - ÜST BİLGİ VE AI ANALİZ KARTI
            VStack(spacing: 12) {
                HStack {
                    Text("Toplam Maliyet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(project.totalCost, specifier: "%.2f") TL")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("✨ AI Analizi")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.purple)
                    Text(AIService.shared.analyzeProject(project: project))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 5))
            .padding()
            
            // MARK: - MALZEME LİSTESİ
            List {
                Section(header: Text("Malzemeler")) {
                    if project.materials.isEmpty {
                        Text("Projeye henüz malzeme eklenmedi.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    } else {
                        ForEach(project.materials) { material in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(material.name)
                                    .font(.headline)
                                
                                let requiredAmount = project.area * material.userPerSquareMeter
                                let totalPrice = requiredAmount * material.pricePerUnit
                                
                                HStack {
                                    Text("Gerekli: \(requiredAmount, specifier: "%.2f") \(material.unit)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(totalPrice, specifier: "%.2f") TL")
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteMaterial) // Kaydırarak silme özelliği
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // MARK: - YENİ MALZEME EKLEME BÖLÜMÜ
            VStack(spacing: 10) {
                Text("Yeni Malzeme Ekle")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("Malzeme Adı", text: $materialName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Birim (kg, m3)", text: $unit)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                
                HStack {
                    TextField("m² Kullanımı", text: $usageRate)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    TextField("Birim Fiyat", text: $price)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                }
                
                // Hata mesajı varsa göster
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: addMaterial) {
                    Text("Malzeme Ekle")
                        .frame(maxWidth: .infinity) // Butonu tam genişlik yaptık
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let url = PDFService.generatePDF(for: project) {
                        pdfURL = url
                        showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up") // PDF butonu artık şık bir paylaşma ikonu
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - YARDIMCI FONKSİYONLAR
    
    func addMaterial() {
        errorMessage = "" // Eski hatayı temizle
        
        // 1. İsim ve birim kontrolü
        let safeName = materialName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if safeName.isEmpty || safeUnit.isEmpty {
            errorMessage = "Lütfen malzeme adını ve birimini girin."
            return
        }
        
        // 2. Ondalık sayıları güvenli hale getirme (Virgülü noktaya çevir)
        let safeUsageStr = usageRate.replacingOccurrences(of: ",", with: ".")
        let safePriceStr = price.replacingOccurrences(of: ",", with: ".")
        
        guard let usage = Double(safeUsageStr), usage > 0 else {
            errorMessage = "Geçerli bir kullanım miktarı girin."
            return
        }
        
        guard let priceValue = Double(safePriceStr), priceValue >= 0 else {
            errorMessage = "Geçerli bir birim fiyat girin."
            return
        }
        
        // 3. Her şey doğruysa malzemeyi ekle
        let material = Material(name: safeName, unit: safeUnit, userPerSquareMeter: usage, pricePerUnit: priceValue)
        material.project = project
        project.materials.append(material) // Modele ekliyoruz
        context.insert(material) // SwiftData'ya kaydediyoruz
        
        do {
            try context.save()
        } catch {
            errorMessage = "Malzeme kaydedilirken hata oluştu."
            return
        }
        
        // İşlem başarılıysa kutuları temizle
        materialName = ""
        unit = ""
        usageRate = ""
        price = ""
    }
    
    // Malzeme silme fonksiyonu
    func deleteMaterial(at offsets: IndexSet) {
        for index in offsets {
            let materialToDelete = project.materials[index]
            context.delete(materialToDelete) // SwiftData'dan sil
            project.materials.remove(at: index) // Ekranda görünen listeden sil
        }
        try? context.save() // Değişikliği veritabanına kaydet
    }
}

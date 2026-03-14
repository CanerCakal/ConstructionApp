//
//  ProjectDetailView.swift
//  ConstructionApp
//

import SwiftUI
import SwiftData
import Charts

struct ProjectDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var project: Project
    
    @State private var pdfDoc: PDFDocumentItem?
    @State private var materialToEdit: Material?
    
    // İnternetten çekilecek katalog ve seçilen malzeme
    @State private var availableMarketMaterials: [MarketMaterial] = []
    @State private var selectedMaterial: MarketMaterial?
    
    // Kullanıcının gireceği miktar ve hata mesajı
    @State private var usageRate: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
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
                .padding(.horizontal)
                
                // MARK: - MALİYET DAĞILIMI GRAFİĞİ (CHART)
                if !project.materials.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Maliyet Dağılımı")
                            .font(.headline)
                        
                        Chart(project.materials) { material in
                            let cost = (project.area * material.userPerSquareMeter) * material.pricePerUnit
                            
                            SectorMark(
                                angle: .value("Maliyet", cost),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Malzeme", material.name))
                        }
                        .frame(height: 220)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 5))
                    .padding(.horizontal)
                }
                
                // MARK: - MALZEME LİSTESİ
                VStack(alignment: .leading, spacing: 10) {
                    Text("Malzemeler")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if project.materials.isEmpty {
                        Text("Projeye henüz malzeme eklenmedi.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.horizontal)
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
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                materialToEdit = material
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteMaterial(material: material)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                // MARK: - YENİ MALZEME EKLEME BÖLÜMÜ
                VStack(spacing: 15) {
                    Text("Katalogdan Malzeme Seç")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Eğer internetten veriler geliyorsa yükleniyor ikonu göster
                    if availableMarketMaterials.isEmpty {
                        ProgressView("Canlı fiyatlar yükleniyor...")
                    } else {
                        // AÇILIR MENÜ (DROPDOWN)
                        Menu {
                            ForEach(availableMarketMaterials) { material in
                                Button("\(material.name) (\(material.currentPriceTRY, specifier: "%.2f") ₺)") {
                                    selectedMaterial = material
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedMaterial?.name ?? "Katalogdan Seçiniz...")
                                    .foregroundColor(selectedMaterial == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                        
                        // Malzeme seçildiyse kullanım miktarını sor
                        if let selected = selectedMaterial {
                            HStack {
                                Text("Birim: \(selected.unit)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Güncel Fiyat: \(selected.currentPriceTRY, specifier: "%.2f") ₺")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            TextField("1 m² için kaç \(selected.unit) kullanılacak?", text: $usageRate)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: addMaterial) {
                        Text("Projeye Ekle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedMaterial == nil) // Malzeme seçilmeden butona basılmasın
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.top)
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // PDF'i oluştur
                    if let url = PDFService.generatePDF(for: project) {
                        // Yeni değer atandığı an SwiftUI sheet'i %100 güvenle açar
                        pdfDoc = PDFDocumentItem(url: url)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(item: $materialToEdit) { selectedMaterial in
            EditMaterialView(material: selectedMaterial)
        }
        // YENİ: showShareSheet yerine doğrudan nesneyi (item) dinliyoruz!
        .sheet(item: $pdfDoc) { doc in
            ShareSheet(activityItems: [doc.url])
        }
        .task {
            do {
                // Sayfa açıldığında canlı verileri API'den çekip kataloğa doldurur
                let (_, materials) = try await NetworkManager.shared.fetchLiveMaterialPrices()
                self.availableMarketMaterials = materials
            } catch {
                errorMessage = "Malzeme kataloğu internetten çekilemedi."
            }
        }
    }
    
    // MARK: - YARDIMCI FONKSİYONLAR
    
    func addMaterial() {
        errorMessage = ""
        
        // Artık yazıyla değil, seçilen nesne üzerinden ilerliyoruz
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
        
        try? context.save()
        
        // İşlem bitince formu temizle
        selectedMaterial = nil
        usageRate = ""
    }
    
    // ContextMenu silme fonksiyonu
    func deleteMaterial(material: Material) {
        if let index = project.materials.firstIndex(where: { $0.id == material.id }) {
            context.delete(material)
            project.materials.remove(at: index)
            try? context.save()
        }
    }
}

struct PDFDocumentItem: Identifiable {
    let id = UUID()
    let url: URL
}

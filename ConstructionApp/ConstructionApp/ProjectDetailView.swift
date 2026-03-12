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
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    
    @State private var materialToEdit: Material?
    
    @State private var materialName: String = ""
    @State private var unit: String = ""
    @State private var usageRate: String = ""
    @State private var price: String = ""
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
                
                // MARK: - YENİ: MALİYET DAĞILIMI GRAFİĞİ (CHART)
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
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: addMaterial) {
                        Text("Malzeme Ekle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
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
                    if let url = PDFService.generatePDF(for: project) {
                        pdfURL = url
                        showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(item: $materialToEdit) { selectedMaterial in
            EditMaterialView(material: selectedMaterial)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - YARDIMCI FONKSİYONLAR
    
    func addMaterial() {
        errorMessage = ""
        let safeName = materialName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if safeName.isEmpty || safeUnit.isEmpty {
            errorMessage = "Lütfen malzeme adını ve birimini girin."
            return
        }
        
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
        
        let material = Material(name: safeName, unit: safeUnit, userPerSquareMeter: usage, pricePerUnit: priceValue)
        material.project = project
        project.materials.append(material)
        context.insert(material)
        
        try? context.save()
        
        materialName = ""
        unit = ""
        usageRate = ""
        price = ""
    }
    
    // YENİ SİLME FONKSİYONU (ContextMenu için uyarlandı)
    func deleteMaterial(material: Material) {
        if let index = project.materials.firstIndex(where: { $0.id == material.id }) {
            context.delete(material)
            project.materials.remove(at: index)
            try? context.save()
        }
    }
}

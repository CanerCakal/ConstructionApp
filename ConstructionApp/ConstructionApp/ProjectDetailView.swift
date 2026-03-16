//
//  ProjectDetailView.swift
//  ConstructionApp
//

import SwiftUI
import SwiftData
import Charts

// PDF Beyaz sayfa sorununu çözen taşıyıcı
struct PDFDocumentItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ProjectDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var project: Project
    
    // Artık bütün verileri ve mantığı Müdür yönetecek
    @StateObject private var viewModel = ProjectDetailViewModel()
    
    // PDF ve Düzenleme Ekranı Kontrolleri
    @State private var pdfDoc: PDFDocumentItem?
    @State private var materialToEdit: Material?
    
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
                        HStack {
                            Text("AI Analizi")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.purple)
                            
                            if viewModel.isAIAnalyzing {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                        }
                        Text(viewModel.aiAnalysesResult)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
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
                                    // Silme işini Müdüre devrettik
                                    viewModel.deleteMaterial(material, from: project, context: context)
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
                    if viewModel.availableMarketMaterials.isEmpty {
                        ProgressView("Canlı fiyatlar yükleniyor...")
                    } else {
                        // AÇILIR MENÜ (DROPDOWN)
                        Menu {
                            ForEach(viewModel.availableMarketMaterials) { material in
                                Button("\(material.name) (\(material.currentPriceTRY, specifier: "%.2f") ₺)") {
                                    viewModel.selectedMaterial = material
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.selectedMaterial?.name ?? "Katalogdan Seçiniz...")
                                    .foregroundColor(viewModel.selectedMaterial == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                        
                        // Malzeme seçildiyse kullanım miktarını sor
                        if let selected = viewModel.selectedMaterial {
                            HStack {
                                Text("Birim: \(selected.unit)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("Güncel Fiyat: \(selected.currentPriceTRY, specifier: "%.2f") ₺")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            TextField("1 m² için kaç \(selected.unit) kullanılacak?", text: $viewModel.usageRate)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        // Ekleme işini Müdüre devrettik
                        viewModel.addMaterial(to: project, context: context)
                    } label: {
                        Text("Projeye Ekle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.selectedMaterial == nil) // Malzeme seçilmeden butona basılmasın
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
        .sheet(item: $pdfDoc) { doc in
            ShareSheet(activityItems: [doc.url])
        }
        .task {
            // Sadece müdüre "İnternetten verileri çek" diyoruz
            await viewModel.loadMarketMaterials()
            await viewModel.fetcAIAnalysis(for: project)
        }
    }
}

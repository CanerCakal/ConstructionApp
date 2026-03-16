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
    
    @StateObject private var viewModel = ProjectDetailViewModel()
    
    // PDF ve Düzenleme Ekranı Kontrolleri
    @State private var pdfDoc: PDFDocumentItem?
    @State private var materialToEdit: Material?
    
    // Animasyon kontrolü
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 1. DİNAMİK ARKA PLAN
            LinearGradient(
                colors: [Theme.bgStart, Theme.bgMid, Theme.bgEnd],
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - ÜST BİLGİ VE AI ANALİZ KARTI
                    VStack(spacing: 12) {
                        HStack {
                            Text("Toplam Maliyet")
                                .font(.headline)
                                .foregroundColor(Theme.text.opacity(0.8))
                            Spacer()
                            Text("\(project.totalCost, specifier: "%.2f") TL")
                                .font(.title2)
                                .bold()
                                .foregroundColor(Theme.accent) // Kehribar vurgusu
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3)) // Çizgiyi temaya uydurduk
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("✨ AI Analizi")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Theme.accent)
                                
                                Spacer() // Başlık ile butonu iki yana ayırıyoruz
                                
                                // Eğer analiz sürüyorsa yükleniyor ikonu göster, sürmüyorsa butonu göster
                                if viewModel.isAIAnalyzing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(Theme.accent)
                                } else {
                                    Button(action: {
                                        // Butona basıldığında analizi başlat
                                        Task {
                                            viewModel.fetcAIAnalysis(for: project)
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "sparkles")
                                            Text("Analiz Et")
                                        }
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(Theme.bgStart) // Koyu renk yazı
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Theme.accent) // Kehribar arka plan
                                        .cornerRadius(8)
                                        .shadow(color: Theme.accent.opacity(0.3), radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                            Text(viewModel.aiAnalysesResult)
                                .font(.caption)
                                .foregroundColor(Theme.text.opacity(0.9))
                                .italic()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - MALİYET DAĞILIMI GRAFİĞİ (CHART)
                    if !project.materials.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Maliyet Dağılımı")
                                .font(.headline)
                                .foregroundColor(Theme.text)
                            
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
                            // Grafik renklerinin koyu temada daha iyi görünmesi için
                            .chartBackground { proxy in
                                Text("₺")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(Theme.text.opacity(0.1))
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    // MARK: - MALZEME LİSTESİ
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Malzemeler")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .padding(.horizontal)
                        
                        if project.materials.isEmpty {
                            Text("Projeye henüz malzeme eklenmedi.")
                                .foregroundColor(Theme.text.opacity(0.6))
                                .font(.subheadline)
                                .padding(.horizontal)
                        } else {
                            ForEach(project.materials) { material in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(material.name)
                                        .font(.headline)
                                        .foregroundColor(Theme.text)
                                    
                                    let requiredAmount = project.area * material.userPerSquareMeter
                                    let totalPrice = requiredAmount * material.pricePerUnit
                                    
                                    HStack {
                                        Text("Gerekli: \(requiredAmount, specifier: "%.2f") \(material.unit)")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.text.opacity(0.7))
                                        Spacer()
                                        Text("\(totalPrice, specifier: "%.2f") TL")
                                            .bold()
                                            .foregroundColor(Theme.accent)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.08)) // Kart içi hafif aydınlatma
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    materialToEdit = material
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
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
                            .foregroundColor(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if viewModel.availableMarketMaterials.isEmpty {
                            ProgressView("Canlı fiyatlar yükleniyor...")
                                .tint(Theme.accent)
                                .foregroundColor(Theme.text)
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
                                        .foregroundColor(viewModel.selectedMaterial == nil ? Theme.text.opacity(0.5) : Theme.text)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Theme.accent)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Malzeme seçildiyse kullanım miktarını sor
                            if let selected = viewModel.selectedMaterial {
                                HStack {
                                    Text("Birim: \(selected.unit)")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.text.opacity(0.7))
                                    Spacer()
                                    Text("Güncel Fiyat: \(selected.currentPriceTRY, specifier: "%.2f") ₺")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.accent)
                                }
                                
                                TextField("1 m² için kaç \(selected.unit)?", text: $viewModel.usageRate)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(Theme.text)
                                    .keyboardType(.decimalPad)
                                    .preferredColorScheme(.dark)
                            }
                        }
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red.opacity(0.9))
                                .font(.caption)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            viewModel.addMaterial(to: project, context: context)
                        } label: {
                            Text("Projeye Ekle")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Theme.bgStart)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(12)
                                .shadow(color: Theme.accent.opacity(0.4), radius: 5, x: 0, y: 3)
                        }
                        .disabled(viewModel.selectedMaterial == nil)
                        // Buton inaktifken rengini soluklaştırmak için
                        .opacity(viewModel.selectedMaterial == nil ? 0.5 : 1.0)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        // Navigation bar yazılarının beyaz olması için
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let url = PDFService.generatePDF(for: project) {
                        pdfDoc = PDFDocumentItem(url: url)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(Theme.accent)
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
            await viewModel.loadMarketMaterials()
        }
    }
}

//
//  MarketPricesView.swift
//  ConstructionApp
//

import SwiftUI

struct MarketPricesView: View {
    @State private var materials: [MarketMaterial] = []
    @State private var liveUSDRate: Double = 0.0 // O anki Dolar kurunu ekranda göstermek için
    
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Canlı piyasa verileri hesaplanıyor...")
                        .foregroundColor(.gray)
                }
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else {
                VStack {
                    // MARK: - ÜST BİLGİ KARTI (CANLI KUR)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Canlı Dolar Kuru")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("1 USD = \(liveUSDRate, specifier: "%.2f") ₺")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 5))
                    .padding()
                    
                    // MARK: - HESAPLANMIŞ MALZEME LİSTESİ
                    List(materials) { material in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(material.name)
                                    .font(.headline)
                                HStack {
                                    Text("Birim: \(material.unit)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("•")
                                        .foregroundColor(.gray)
                                    Text("Baz: $\(material.basePriceUSD, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                            
                            // Canlı kur ile çarpılmış güncel TL fiyatı
                            Text("\(material.currentPriceTRY, specifier: "%.2f") ₺")
                                .bold()
                                .foregroundColor(.primary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle("Güncel Maliyetler")
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        do {
            // NetworkManager'dan hem güncel kuru hem de hesaplanmış listeyi alıyoruz
            let result = try await NetworkManager.shared.fetchLiveMaterialPrices()
            self.liveUSDRate = result.0
            self.materials = result.1
        } catch {
            errorMessage = "Fiyatlar hesaplanırken bir hata oluştu."
            print("API Hatası: \(error)")
        }
        isLoading = false
    }
}

//
//  MarketPricesView.swift
//  ConstructionApp
//

import SwiftUI

struct MarketPricesView: View {
    // Çekilen verileri tutacağımız dizi
    @State private var marketMaterials: [MarketMaterial] = []
    
    // Yükleniyor animasyonunu kontrol eden değişken
    @State private var isLoading: Bool = true
    @State private var errorMessage: String = ""
    
    var body: some View {
        Group {
            if isLoading {
                // İnternet beklenirken dönen Apple'ın standart yükleme ikonu
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Canlı fiyatlar çekiliyor...")
                        .foregroundColor(.gray)
                }
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else {
                List(marketMaterials) { material in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(material.name)
                                .font(.headline)
                            Text("Birim: \(material.unit)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(material.price, specifier: "%.2f") TL")
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Piyasa Fiyatları")
        // YENİ: .task özelliği, ekran açıldığı anda otomatik olarak içindeki işlemi başlatır
        .task {
            await loadData()
        }
    }
    
    // MARK: - İNTERNETE BAĞLANMA İŞLEMİ
    private func loadData() async {
        isLoading = true // Yükleniyor ekranını aç
        do {
            // Kuryeyi (NetworkManager) gönder ve cevap gelene kadar burada bekle (await)
            marketMaterials = try await NetworkManager.shared.fetchMarketPrices()
        } catch {
            errorMessage = "Veriler çekilirken hata oluştu."
        }
        isLoading = false // Veri geldi, yükleniyor ekranını kapat
    }
}

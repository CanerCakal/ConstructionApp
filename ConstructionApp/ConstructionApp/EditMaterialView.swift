//
//  EditMaterialView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 11.03.2026.
//

import SwiftUI
import SwiftData

struct EditMaterialView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @Bindable var material: Material
    
    @State private var editName: String = ""
    @State private var editUnit: String = ""
    @State private var editUsage: String = ""
    @State private var editPrice: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Malzeme Bilgileri")) {
                    TextField("Malzeme Adı:", text: $editName)
                    TextField("Birim (kg, m3):", text: $editUnit)
                    TextField("m2 kullanımı:", text: $editUsage)
                        .keyboardType(.decimalPad)
                    TextField("Birim Fiyat:", text: $editPrice)
                        .keyboardType(.decimalPad)
                }
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .navigationTitle("Malzemeyi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveChanges()
                    }
                    .bold()
                }
            }
            .onAppear {
                editName = material.name
                editUnit = material.unit
                
                editUsage = formatNumber(material.userPerSquareMeter)
                editPrice = formatNumber(material.pricePerUnit)
            }
        }
    }
    
    //MARK: Yardımcı Fonksiyonlar
    
    private func saveChanges() {
        errorMessage = ""
        
        let safeName = editName.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeUnit = editUnit.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if safeName.isEmpty || safeUnit.isEmpty {
            errorMessage = "İsim ve birim boş bırakılamaz!"
                return
        }
        
        let safeUsageStr = editUsage.replacingOccurrences(of: ",", with: ".")
        let safePriceStr = editPrice.replacingOccurrences(of: ",", with: ".")
        
        guard let usage = Double(safeUsageStr), usage > 0 else {
            errorMessage = "Lütfen geçerli bir kullanım miktarı giriniz"
            return
        }
        
        guard let priceValue = Double(safePriceStr), priceValue >= 0 else {
            errorMessage = "Lütfen geçerli bir birim fiyat giriniz."
            return
        }
        
        material.name = safeName
        material.unit = safeUnit
        material.userPerSquareMeter = usage
        material.pricePerUnit = priceValue
        
        try? context.save()
        dismiss()
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}


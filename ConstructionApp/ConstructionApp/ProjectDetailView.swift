//
//  ProjectDetailView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 28.02.2026.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var project: Project
    
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var materialName: String = ""
    @State private var unit: String = ""
    @State private var usageRate: String = ""
    @State private var price: String = ""
    
    var body: some View {
        VStack {
            
            VStack(spacing: 8) {
                Text("Toplam Maliyet")
                    .font(.headline)
                Text("\(project.totalCost, specifier: "%.2f") TL")
                    .font(.title)
                    .bold()
                    .foregroundColor(.green)
            }.padding()
            
            VStack {
                Text("AI Analizi")
                    .font(.headline)
                Text(AIService.shared.analyzeProject(project: project))
                    .foregroundColor(.purple)
            }.padding()
            
            List {
                ForEach(project.materials) { material in
                    VStack(alignment: .leading) {
                        Text(material.name)
                            .font(.headline)
                        
                        let requiredAmount = project.area * material.userPerSquareMeter
                        let totalPrice = requiredAmount * material.pricePerUnit
                        
                        Text("Gerekli: \(requiredAmount, specifier: "%.2f") \(material.unit)")
                        Text("Toplam Fiyat: \(totalPrice, specifier: "%.2f") TL")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            VStack(spacing: 10) {
                TextField("Malzeme Adı", text: $materialName)
                    .textFieldStyle(.roundedBorder)
                TextField("Birim(kg, m3 vs)", text: $unit)
                    .textFieldStyle(.roundedBorder)
                TextField("m2 başına kullanım", text: $usageRate)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                TextField("Birim Fiyat", text: $price)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Button("Malzeme Ekle") {
                    addMaterial()
                }
                .buttonStyle(.borderedProminent)
            }.padding()
            
        }
        .navigationTitle(project.name)
        .toolbar {
            Button("PDF") {
                if let url = PDFService.generatePDF(for: project) {
                    pdfURL = url
                    showShareSheet = true
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    func addMaterial() {
        guard let usage = Double(usageRate),
              let priceValue = Double(price)
        else { return }
        let material = Material(name: materialName, unit: unit, userPerSquareMeter: usage, pricePerUnit: priceValue)
        material.project = project
        project.materials.append(material)
        context.insert(material)
        
        materialName = ""
        unit = ""
        usageRate = ""
        price = ""
    }
}


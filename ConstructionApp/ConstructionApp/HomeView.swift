//
//  HomeView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    
    @Environment(\.modelContext) private var context
    @Query private var projects: [Project]
    
    @State private var newProjectName: String = ""
    @State private var newProjectArea: String = ""
    
    var totalPortfolioCost: Double {
        projects.reduce(0) { $0 + $1.totalCost}
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Toplam Proje: \(projects.count)")
                    .font(.headline)
                
                Text("Genel Maaliyet")
                
                Text("\(totalPortfolioCost, specifier: "%.2f") TL")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding()
            
            Divider()
            
            List {
                ForEach(projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        VStack(alignment: .leading) {
                            Text(project.name)
                                .font(.headline)
                            Text(project.name)
                                .font(.headline)
                            Text("Alan: \(project.area, specifier: "%.2f") m2")
                            Text("Toplam: \(project.totalCost, specifier: "%.2f") TL")
                                .foregroundColor(.green)
                        }
                    }
                }
                .onDelete(perform: deleteProject)
            }
            VStack(spacing: 10) {
                TextField("Proje Adı", text: $newProjectName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Alan(m2)", text: $newProjectArea)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                
                Button("Proje Ekle") {
                    addProject()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Projeler")
        .toolbar {
            Button("Çıkış") {
                authViewModel.logOut()
            }
        }
    }
    
    func addProject() {
        guard let area = Double(newProjectArea) else { return }
        let project = Project(name: newProjectName, area: area)
        context.insert(project)
        newProjectName = ""
        newProjectArea = ""
    }
    
    func deleteProject(at offsets: IndexSet) {
        for index in offsets {
            context.delete(projects[index])
        }
    }
}

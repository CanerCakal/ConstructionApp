//
//  HomeView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var projects: [Project]
    
    @State private var newProjectName: String = ""
    @State private var newProjectArea: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        Text(project.name)
                            .font(.headline)
                        Text("Alan: \(project.area, specifier: "%.2f") m2")
                            .font(.subheadline)
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

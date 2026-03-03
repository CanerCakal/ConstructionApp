//
//  HomeView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.modelContext) private var context
    @Query private var projects: [Project]
    
    @State private var newProjectName: String = ""
    @State private var newProjectArea: String = ""
    
    var totalPortfolioCost: Double {
        projects.reduce(0) { $0 + $1.totalCost}
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Toplam Proje")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(projects.count)")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Genel Maaliyet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(totalPortfolioCost, specifier: "%.2f") TL")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }
                }.padding()
                    .background(RoundedRectangle(cornerRadius: 20) .fill(Color(.systemBackground)) .shadow(color: .black.opacity(0.1), radius: 10)) .padding(.horizontal)
                
                List {
                    ForEach(projects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(project.name)
                                    .font(.headline)
                                HStack {
                                    Text("\(project.area, specifier: "%.2f") m2")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(project.totalCost, specifier: "%.2f") TL")
                                        .bold()
                                        .foregroundColor(.green)
                                }
                            }.padding()
                                .background(RoundedRectangle(cornerRadius: 16) .fill(Color(.secondarySystemBackground)))
                        }.listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }.onDelete(perform: deleteProject)
                }.listStyle(.plain)
                
                VStack(spacing: 10) {
                    TextField("Proje Adı", text: $newProjectName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Alan(m2)", text: $newProjectArea)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Button("Proje Ekle") {
                        addProject()
                    }.buttonStyle(.borderedProminent)
                    Button("Sunucu Test") {
                        Task {
                            do {
                                let result = try await NetworkManager.shared.fetcSampleData()
                                print(result)
                            } catch {
                                print("Hata:", error.localizedDescription)
                            }
                        }
                    }.buttonStyle(.bordered)
                }.padding()
            }.navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    Button("Çıkış") {
                        authViewModel.logOut()
                    }
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

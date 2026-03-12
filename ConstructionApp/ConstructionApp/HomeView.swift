//
//  HomeView.swift
//  ConstructionApp
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var context
    
    // Projeleri tarihe göre sıralı getirmek her zaman daha profesyoneldir
    @Query(sort: \Project.createdAt, order: .reverse) private var allProjects: [Project]
    
    var myProjects: [Project] {
        allProjects.filter { $0.owner?.email == authViewModel.email}
    }
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - ÜST BİLGİ KARTLARI (DASHBOARD)
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Toplam Proje")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(myProjects.count)")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Genel Maliyet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(viewModel.calculateTotalCost(for: myProjects), specifier: "%.2f")")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 10))
                .padding(.horizontal)
                
                // MARK: - PROJELER LİSTESİ
                List {
                    ForEach(myProjects) { project in
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
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteProject(at: indexSet, from: myProjects, context: context)
                    }
                }
                .listStyle(.plain)
                
                // MARK: - YENİ PROJE EKLEME BÖLÜMÜ
                VStack(spacing: 10) {
                    Divider() // Araya ince bir çizgi çektik
                    
                    Text("Yeni Proje Oluştur")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    TextField("Proje Adı", text: $viewModel.newProjectName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Alan (m2)", text: $viewModel.newProjectArea)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    
                    // Hata mesajı alanı
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 15) {
                        Button("Proje Ekle") {
                            viewModel.addProject(context: context, currentUserEmail: authViewModel.email)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color(.systemGray6)) // Ekleme alanını hafif gri yaparak belirginleştirdik
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: MarketPricesView()) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Piyasa")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Çıkış") {
                        authViewModel.logOut()
                    }
                }
            }
        }
    }
}

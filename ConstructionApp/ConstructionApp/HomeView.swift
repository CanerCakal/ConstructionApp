//
//  HomeView.swift
//  ConstructionApp
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Project.createdAt, order: .reverse) private var allProjects: [Project]
    
    var myProjects: [Project] {
        allProjects.filter { $0.owner?.email == authViewModel.email}
    }
    
    @StateObject private var viewModel = HomeViewModel()
    
    // Animasyon için State değişkenimiz
    @State private var isAnimating = false
    
    var body: some View {
        // YENİ: NavigationView yerine modern ve uyumlu NavigationStack kullanıyoruz
        NavigationStack {
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
                
                VStack(spacing: 20) {
                    
                    // MARK: - ÜST BİLGİ KARTLARI (DASHBOARD) - BUZLU CAM EFEKTİ
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Toplam Proje")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.text.opacity(0.7))
                                Text("\(myProjects.count)")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(Theme.text)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("Genel Maliyet")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.text.opacity(0.7))
                                Text("\(viewModel.calculateTotalCost(for: myProjects), specifier: "%.2f") TL")
                                    .font(.title2)
                                    .bold()
                                    // Vurgu rengimizi (Kehribar) kullanıyoruz
                                    .foregroundColor(Theme.accent)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial) // Buzlu cam arka plan
                    .cornerRadius(20)
                    .overlay( // İnce, şık beyaz çerçeve
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - PROJELER LİSTESİ
                    List {
                        ForEach(myProjects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(project.name)
                                        .font(.headline)
                                        .foregroundColor(Theme.text)
                                    
                                    HStack {
                                        Text("\(project.area, specifier: "%.2f") m2")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.text.opacity(0.7))
                                        
                                        Spacer()
                                        
                                        Text("\(project.totalCost, specifier: "%.2f") TL")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(Theme.accent)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            // Kartların arka planını buzlu cam yapıyoruz
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .padding(.vertical, 4)
                            )
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteProject(at: indexSet, from: myProjects, context: context)
                        }
                    }
                    .listStyle(.plain)
                    // YENİ: List'in varsayılan gri/beyaz arka planını şeffaf yapıyoruz ki kendi arka planımız görünsün
                    .scrollContentBackground(.hidden)
                    
                    // MARK: - YENİ PROJE EKLEME BÖLÜMÜ
                    VStack(spacing: 15) {
                        Text("Yeni Proje Oluştur")
                            .font(.headline)
                            .foregroundColor(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Proje Adı TextField
                        TextField("Proje Adı", text: $viewModel.newProjectName)
                            .padding()
                            .background(Color.white.opacity(0.1)) // Yarı saydam arka plan
                            .cornerRadius(10)
                            .foregroundColor(Theme.text)
                            .preferredColorScheme(.dark)
                        
                        // Alan TextField
                        TextField("Alan (m2)", text: $viewModel.newProjectArea)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(Theme.text)
                            .keyboardType(.decimalPad)
                            .preferredColorScheme(.dark)
                        
                        // Hata mesajı alanı
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red.opacity(0.9))
                                .font(.caption)
                                .bold()
                        }
                        
                        // Ekle Butonu
                        Button(action: {
                            viewModel.addProject(context: context, currentUserEmail: authViewModel.email)
                        }) {
                            Text("Proje Ekle")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Theme.bgStart) // Yazıyı koyu mavi yapıp, butonu sarı yapıyoruz
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(12)
                                .shadow(color: Theme.accent.opacity(0.4), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial) // Alt bölüm de cam oldu
                    .cornerRadius(20, corners: [.topLeft, .topRight]) // Sadece üst köşeleri yuvarlattık
                    .ignoresSafeArea(.all, edges: .bottom)
                }
            }
            .navigationTitle("Projelerim")
            .toolbarColorScheme(.dark, for: .navigationBar) // Navigation bar yazılarının beyaz olmasını sağlar
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MarketPricesView()) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(Theme.accent)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        authViewModel.logOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
        }
    }
}

// Belirli köşeleri yuvarlatmak için kullandığımız küçük bir SwiftUI eklentisi (Extension)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    
    @State private var newProjectName: String = ""
    @State private var newProjectArea: String = ""
    
    // Kullanıcıya göstereceğimiz hata veya uyarı mesajı
    @State private var errorMessage: String = ""
    
    var totalPortfolioCost: Double {
        projects.reduce(0) { $0 + $1.totalCost}
    }
    
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
                            Text("\(projects.count)")
                                .font(.title)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Genel Maliyet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(totalPortfolioCost, specifier: "%.2f") TL")
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
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteProject)
                }
                .listStyle(.plain)
                
                // MARK: - YENİ PROJE EKLEME BÖLÜMÜ
                VStack(spacing: 10) {
                    Divider() // Araya ince bir çizgi çektik
                    
                    Text("Yeni Proje Oluştur")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    TextField("Proje Adı", text: $newProjectName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Alan (m2)", text: $newProjectArea)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    
                    // Hata mesajı alanı
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    HStack(spacing: 15) {
                        Button("Proje Ekle") {
                            addProject()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // İleride sileceğimiz test butonumuz şimdilik burada kalsın
                        Button("Sunucu Test") {
                            Task {
                                do {
                                    let result = try await NetworkManager.shared.fetcSampleData()
                                    print(result)
                                } catch {
                                    print("Hata:", error.localizedDescription)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(.systemGray6)) // Ekleme alanını hafif gri yaparak belirginleştirdik
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("Çıkış") {
                    authViewModel.logOut()
                }
            }
        }
    }
    
    // MARK: - YARDIMCI FONKSİYONLAR
    
    func addProject() {
        errorMessage = "" // Her basışta eski hatayı temizle
        
        // 1. İsim kontrolü: Sadece boşluklardan oluşan girişleri engellemek için metni temizliyoruz
        let trimmedName = newProjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            errorMessage = "Lütfen geçerli bir proje adı giriniz."
            return
        }
        
        // 2. Alan (m2) kontrolü: Hem sayıya çevrilebiliyor mu, hem de 0'dan büyük mü diye bakıyoruz
        guard let area = Double(newProjectArea), area > 0 else {
            errorMessage = "Lütfen sıfırdan büyük geçerli bir alan (m2) değeri giriniz."
            return
        }
        
        // 3. Her şey doğruysa projeyi ekle
        let project = Project(name: trimmedName, area: area)
        context.insert(project)
        
        // 4. İşlem başarılı olduktan sonra alanları temizle
        newProjectName = ""
        newProjectArea = ""
        errorMessage = ""
    }
    
    func deleteProject(at offsets: IndexSet) {
        for index in offsets {
            context.delete(projects[index])
        }
    }
}

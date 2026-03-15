//
//  SplashView.swift
//  ConstructionApp
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.7
    @State private var opacity = 0.4
    
    // AuthViewModel ve SwiftData veritabanını RootView'a aktarmak için
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if isActive {
            // 2 Saniye sonra asıl uygulamamıza (RootView) geçiş yapacak
            RootView()
        } else {
            // AÇILIŞ EKRANI TASARIMI
            ZStack {
                // Arka Plan Rengi (Kurumsal Koyu Lacivert/Blueprint Rengi)
                Color(red: 0.05, green: 0.15, blue: 0.25)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // İkonun / Logonun Temsili
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 150, height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        Text("CM")
                            .font(.system(size: 70, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    
                    // Alt Yazı
                    Text("CONSTRUCTION MANAGER")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2) // Harfler arasına boşluk katar
                }
                // Animasyon Değerleri
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    // Ekran açıldığında yavaşça büyü ve belirginleş animasyonu
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                // Ekran açıldıktan 2.5 saniye sonra isActive'i true yapıp ana sayfaya geç
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

//
//  LoginView.swift
//  ConstructionApp
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                
                VStack(spacing: 30) {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Theme.accent)
                            .shadow(color: Theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Yapı Asistanı")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(Theme.text)
                        
                        Text("Projelerinizi güvenle yönetin")
                            .font(.subheadline)
                            .foregroundColor(Theme.text.opacity(0.7))
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
                        // Email Alanı
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Theme.accent)
                                .frame(width: 30)
                            
                            // YENİ: Veriyi doğrudan authViewModel'a yazdırıyoruz
                            TextField("E-posta adresiniz", text: $authViewModel.email)
                                .foregroundColor(Theme.text)
                                .autocapitalization(.none)
                                .preferredColorScheme(.dark)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Şifre Alanı
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Theme.accent)
                                .frame(width: 30)
                            
                            // YENİ: Veriyi doğrudan authViewModel'a yazdırıyoruz
                            SecureField("Şifreniz", text: $authViewModel.password)
                                .foregroundColor(Theme.text)
                                .preferredColorScheme(.dark)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Hata Mesajı Gösterimi
                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(Color.red.opacity(0.9))
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                        }
                        
                        // Giriş Butonu
                        Button(action: {
                            authViewModel.login()
                        }) {
                            Text("Giriş Yap")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(15)
                                .shadow(color: Theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    
                    NavigationLink(destination: RegisterView()) {
                        HStack(spacing: 5) {
                            Text("Hesabın yok mu?")
                                .foregroundColor(Theme.text.opacity(0.7))
                            Text("Kayıt Ol")
                                .fontWeight(.bold)
                                .foregroundColor(Theme.accent)
                        }
                        .font(.footnote)
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
        }
    }
}

//
//  RegisterView.swift
//  ConstructionApp
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss // Sayfayı kapatıp geri dönmek için
    
    @State private var email = ""
    @State private var password = ""
    @State private var isAnimating = false
    
    var body: some View {
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
            
            VStack(spacing: 30) {
                
                // Başlık ve İkon
                VStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 70))
                        .foregroundStyle(Theme.accent)
                        .shadow(color: Theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Yeni Hesap")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Theme.text)
                    
                    Text("Aramıza katılın, projelere başlayın")
                        .font(.subheadline)
                        .foregroundColor(Theme.text.opacity(0.7))
                }
                .padding(.bottom, 20)
                
                // Kayıt Formu
                VStack(spacing: 20) {
                    // Email Alanı
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Theme.accent)
                            .frame(width: 30)
                        
                        TextField("E-posta adresiniz", text: $email)
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
                        
                        SecureField("Şifreniz", text: $password)
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
                    
                    // Hata Mesajı
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(Color.red.opacity(0.9))
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.top, 5)
                    }
                    
                    // Kayıt Ol Butonu
                    Button(action: {
                        authViewModel.register(emailInput: email, passwordInput: password)
                    }) {
                        Text("Kayıt Ol")
                            .font(.headline)
                            .bold()
                            .foregroundColor(Theme.bgStart) // Yazı koyu, buton sarı
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(15)
                            .shadow(color: Theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        // Üstteki standart çubuğu gizleyip kendi şık geri butonumuzu ekliyoruz
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                    .foregroundColor(Theme.accent)
                }
            }
        }
    }
}

//
//  RegisterView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 5.03.2026.
//

import SwiftUI

struct RegisterView: View {
    // AuthViewModel'e erişim sağlıyoruz ki register fonksiyonunu kullanabilelim.
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Sayfaya özel değişkenler. ViewModel ile çakışmayı önler!
    @State private var registerEmail: String = ""
    @State private var registerPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var localErrorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Yeni Hesap Oluştur")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $registerEmail)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress) // Klavye tipini email için ayarlıyoruz.
            
            SecureField("Şifre", text: $registerPassword)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Şifre(Tekrar)", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            //Hata mesajlarını gösterdiğimiz alan
            if !localErrorMessage.isEmpty {
                Text(localErrorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            } else if !authViewModel.errorMesage.isEmpty {
                Text(authViewModel.errorMesage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button("Kayıt Ol") {
                registerUser()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
        }
        .padding()
        .navigationTitle("Kayıt Ol")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Sayfa ilk açıldığında eski hata mesajlarını temizle
            authViewModel.errorMesage = ""
        }
    }
    
    //MARK: Yardımcı Fonksiyonlar
    ///Kullanıcı verilerini kontrol edip kayıt işlemini başlatırlar
    private func registerUser() {
        
        // 1. Alanların boş olup olmadığını kontrol et
        if registerEmail.isEmpty || registerPassword.isEmpty {
            localErrorMessage = "Lütfen tüm alanları doldurunuz!"
            return
        }
        
        // 2. Şifrelerin eşleşip eşleşmediğini kontrol et
        if registerPassword != confirmPassword {
            localErrorMessage = "Şifreler eşleşmiyor!!"
            return
        }
        
        // Her şey yolundaysa ViewModel üzerinden kayıt işlemini yap
        localErrorMessage = ""
        
        // İşlemi sayfanın kendi değişkenleriyle ViewModel'e gönderiyoruz
        authViewModel.register(emailInput: registerEmail, passwordInput: registerPassword)
    }
}

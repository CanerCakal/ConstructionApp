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
    // Kullanıcı kayıt olduktan sonra giriş ekranına geri dönebilmek için kullanacağız.
    @Environment(\.dismiss) var dismiss
    // Sadece bu ekranda kullanılacak şifre tekrarı değişkeni
    @State private var confirmPassword: String = ""
    @State private var localErrorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Yeni Hesap Oluştur")
                .font(.largeTitle)
                .bold()
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress) // Klavye tipini email için ayarlıyoruz.
            SecureField("Şifre", text: $authViewModel.password)
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
                authViewModel.login()
            }.buttonStyle(.borderedProminent)
            Spacer()
        }.padding()
            .navigationTitle("Kayıt Ol")
            .navigationBarTitleDisplayMode(.inline)
    }
    //MARK: Yardımcı Fonksiyonlar
    ///Kullanıcı verilerini kontrol edip kayıt işlemini başlatırlar
    private func registerUser() {
        
        // 1. Alanların boş olup olmadığını kontrol et
        if authViewModel.email.isEmpty || authViewModel.password.isEmpty {
            localErrorMessage = "Lütfen tüm alanları doldurunuz!"
            return
        }
        
        // 2. Şifrelerin eşleşip eşleşmediğini kontrol et
        if authViewModel.password != confirmPassword {
            localErrorMessage = "Şifreler eşleşmiyor!!"
            return
        }
        
        // Her şey yolundaysa ViewModel üzerinden kayıt işlemini yap
        localErrorMessage = ""
        authViewModel.register()
        
        // Kayıt başarılıysa bir önceki ekrana (Giriş ekranına) dön
        if authViewModel.errorMesage == "Kayıt Başarılı" {
            dismiss()
        }
    }
}

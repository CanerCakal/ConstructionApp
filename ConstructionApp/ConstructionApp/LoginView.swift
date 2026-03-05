//
//  LoginView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer() // İçeriği ortalamak için
            
            Text("Construction Manager")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(.roundedBorder)
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Button("Giriş Yap") {
                authViewModel.login()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            NavigationLink("Hesabınız yok mu? Kayıt Olun") {
                RegisterView()
            }.padding(.bottom, 20)
        }
        .padding()
    }
}


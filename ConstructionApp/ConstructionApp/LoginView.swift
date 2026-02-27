//
//  LoginView.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Construction Manager")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
            }
            
            Button("Giriş Yap") {
                viewModel.login()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


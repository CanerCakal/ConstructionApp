//
//  AuthViewModel.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import Foundation
import SwiftUI
internal import Combine

class AuthViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    func login() {
        if email == "admin@test.com" && password == "1234" {
            isLoggedIn = true
            errorMessage = ""
        } else {
            errorMessage = "Kullanıcı adı veya şifre yanlış!"
        }
    }
}

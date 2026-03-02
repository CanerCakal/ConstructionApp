//
//  AuthViewModel.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import Foundation
import SwiftUI
internal import Combine
import CryptoKit
import SwiftData

class AuthViewModel: ObservableObject {
    
    private var context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }
    
    @Query private var users: [User]
    
    @Published var failedAttempts = 0
    @Published var lockUntil: Date?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    private func generateSalt() -> String {
        UUID().uuidString
    }
    
    private func hashPassword( _ password: String, salt: String) -> String {
        let combined = password + salt
        let data = Data(combined.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map {
            String(format: "02x", $0)
        }.joined()
    }
    
    func register() {
        let salt = generateSalt()
        let hashedPassword = hashPassword(password, salt: salt)
        
        let newUser = User(email: email, passwordHash: hashedPassword, salt: salt)
        context.insert(newUser)
        
        do {
            try context.save()
            errorMessage = "Kayıt Başarılı"
        } catch {
            errorMessage = "Kayıt sırasında hata oluştu!!"
        }
    }
    
    func login() {
        
        if let lockUntil = lockUntil, Date() < lockUntil {
            errorMessage = "Çok fazla deneme yaptınız. Lütfen bekleyiniz."
            return
        }
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == email })
        
        do {
            
            let fetchedUsers = try context.fetch(descriptor)
            guard let user = fetchedUsers.first else {
                errorMessage = "Kullanıcı bulunamadı"
                return
            }
            let hashedInput = hashPassword(password, salt: user.salt)
            
            if hashedInput == user.passwordHash {
                isLoggedIn = true
                errorMessage = ""
                failedAttempts = 0
            } else {
                handleFailedAttempt()
            }
            
        } catch {
            errorMessage = "Giriş sırasında hata oluştu"
        }
    }
    
    private func handleFailedAttempt() {
        failedAttempts += 1
        
        if failedAttempts >= 5 {
            lockUntil = Date().addingTimeInterval(10)
            errorMessage = "5 Hatalı deneme. Lütfen 30 saniye bekleyiniz"
        } else {
            errorMessage = "Şifre yanlış"
        }
    }
    
    func logOut() {
        email = ""
        password = ""
        isLoggedIn = false
    }
}

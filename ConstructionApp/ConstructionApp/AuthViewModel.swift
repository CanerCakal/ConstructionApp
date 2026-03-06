import Foundation
import Combine
import SwiftUI
import SwiftData

class AuthViewModel: ObservableObject {
    
    var context: ModelContext?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMesage: String = ""
    
    // Kilitlenme mekanizması için
    @Published var failedAttempts: Int = 0
    @Published var lockUntil: Date?
    
    init() {}
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // Uygulama ilk açıldığında çalışan test hesabı oluşturucu
    func createdDefaultAdminIfNeded() {
        guard let context = context else { return }
        let descriptor = FetchDescriptor<User>()
        
        if let user = try? context.fetch(descriptor), user.isEmpty {
            let admin = User(email: "admin@test.com", passwordHash: "1234", salt: "")
            context.insert(admin)
            try? context.save()
            print("Admin hesabı oluşturuldu")
        }
    }
    // MARK: - KAYIT OLMA FONKSİYONU (YENİ VE OTOMATİK GİRİŞLİ)
    func register(emailInput: String, passwordInput: String) {
        errorMesage = ""
        
        guard let dbContext = self.context else {
            errorMesage = "Veritabanı bağlantısı yok"
            return
        }
        
        let safeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        do {
            // E-posta zaten kayıtlı mı diye manuel kontrol ediyoruz
            let descriptor = FetchDescriptor<User>()
            let allUsers = try dbContext.fetch(descriptor)
            
            if allUsers.contains(where: { $0.email == safeEmail }) {
                errorMesage = "Bu e-posta adresi zaten kullanılıyor."
                return
            }
            
            let newUser = User(email: safeEmail, passwordHash: password, salt: "")
            dbContext.insert(newUser)
            try dbContext.save()
            
            self.email = safeEmail
            self.password = passwordInput
            self.isLoggedIn = true
            self.errorMesage = ""
            print("Kayıt başarılı ve otomatik giriş yapıldı: \(safeEmail)")
            
        } catch {
            errorMesage = "Kayıt sırasında hata oluştu."
            print("Hata detayı: \(error)")
        }
    }
    
    //MARK: Giriş yapma fonksiyonu
    func login() {
        errorMesage = ""
        
        // 30 saniye kilidi devrede mi?
        if let lockUntil = lockUntil, Date() < lockUntil {
            errorMesage = "Çok fazla deneme yaptınız. Lütfen bekleyiniz."
            return
        }
        
        guard let context = context else {
            errorMesage = "Veritabanı bağlantısı yok."
            return
        }
        
        let safeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let descriptor = FetchDescriptor<User>()
        
        do {
            let allUsers = try context.fetch(descriptor)
            guard let user = allUsers.first(where: { $0.email == safeEmail }) else {
                handleFailedAttempts(message: "Kullanıcı Bulunamadı")
                return
            }
            if user.passwordHash == password {
                isLoggedIn = true
                errorMesage = ""
                failedAttempts = 0
                print("Başarıyla giriş yapıldı \(safeEmail)")
            } else {
                handleFailedAttempts(message: "Şifre yanlış")
            }
        } catch {
            errorMesage = "Giriş sırasında bir hata oluştu"
        }
    }
    // Hatalı girişleri yöneten fonksiyon
    func handleFailedAttempts(message: String) {
        failedAttempts += 1
        if failedAttempts >= 5 {
            lockUntil = Date().addingTimeInterval(30)
            errorMesage = "5 hatalı deneme yaptınız. Lütfen bekleyiniz"
        } else {
            errorMesage = message
        }
    }
    
    func logOut() {
        email = ""
        password = ""
        isLoggedIn = false
        failedAttempts = 0
    }
    
    func checkSession() {
        
    }
}

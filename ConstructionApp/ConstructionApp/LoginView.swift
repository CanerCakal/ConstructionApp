import SwiftUI

struct LoginView: View {
    
    // BURASI ÇOK ÖNEMLİ: @EnvironmentObject kelimesi mutlaka olmalı
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Spacer()
                
                Text("Construction Manager")
                    .font(.largeTitle)
                    .bold()
                
                // Veri girişi yapılan yerlerde $ işareti KULLANILIR
                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                // Veri girişi yapılan yerlerde $ işareti KULLANILIR
                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(.roundedBorder)
                
                // Veri okunan yerlerde $ işareti KULLANILMAZ
                if !authViewModel.errorMesage.isEmpty {
                    Text(authViewModel.errorMesage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                Button("Giriş Yap") {
                    // Fonksiyon çağrılırken $ işareti KULLANILMAZ
                    authViewModel.login()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                NavigationLink("Hesabınız yok mu? Kayıt Olun") {
                    RegisterView()
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
}

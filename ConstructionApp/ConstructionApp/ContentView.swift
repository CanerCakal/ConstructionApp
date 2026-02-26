import SwiftUI

struct ContentView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                Text("Hoşgeldin \(email)")
                    .font(.title)
            } else {
                VStack(spacing: 20) {
                    Text("Construction Manager")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                    
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                    
                    Button("Giriş Yap") {
                        login()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
    
    func login() {
        if email == "admin@test.com" && password == "1234" {
            isLoggedIn = true
            errorMessage = ""
        } else {
            errorMessage = "Email veya şifre yanlış!"
        }
    }
}

#Preview {
    ContentView()
}

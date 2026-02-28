import SwiftUI

struct ContentView: View {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            if authViewModel.isLoggedIn {
                HomeView(authViewModel: authViewModel)
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}


import SwiftUI

struct ContentView: View {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}

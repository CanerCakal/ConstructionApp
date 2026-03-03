import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}



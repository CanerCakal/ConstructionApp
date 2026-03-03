import SwiftUI
import SwiftData

struct RootView: View {
    
    @Environment(\.modelContext) private var context
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ContentView()
            .environmentObject(authViewModel)
            .onAppear {
                authViewModel.setContext(context)
                authViewModel.createDefaultAdminIfNeeded()
                authViewModel.checkSession()
            }
    }
}

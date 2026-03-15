import SwiftUI
import SwiftData

@main
struct ConstructionAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashView() // <-- BURAYI DEĞİŞTİRDİK
                .environmentObject(authViewModel)
                .modelContainer(for: [User.self, Project.self, Material.self])
        }
    }
}

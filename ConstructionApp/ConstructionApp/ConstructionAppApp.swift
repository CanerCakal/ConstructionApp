//
//  ConstructionAppApp.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 26.02.2026.
//

import SwiftUI
import SwiftData

@main
struct ConstructionAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Project.self)
    }
}

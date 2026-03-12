//
//  HomeViewModel.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 12.03.2026.
//

import Foundation
import SwiftData
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var newProjectName: String = ""
    @Published var newProjectArea: String = ""
    @Published var errorMessage: String = ""
    
    func calculateTotalCost(for projects: [Project]) -> Double {
        return projects.reduce(0) { $0 + $1.totalCost }
    }
    
    func addProject(context: ModelContext, currentUserEmail: String) {
        errorMessage = ""
        
        let trimnedName = newProjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimnedName.isEmpty {
            errorMessage = "Lütfen geçerli bir proje adı giriniz!"
            return
        }
        
        let safeAreaStr = newProjectArea.replacingOccurrences(of: ",", with: ".")
        guard let area = Double(safeAreaStr), area > 0 else {
            errorMessage = "Lütfen sıfırdan büyük geçerli bir alan (m2) giriniz"
            return
        }
        
        let project = Project(name: trimnedName, area: area)
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == currentUserEmail })
        if let currentUser = try? context.fetch(descriptor).first {
            project.owner = currentUser
        }
        context.insert(project)
        
        errorMessage = ""
        newProjectArea = ""
        newProjectName = ""
    }
    
    func deleteProject(at offset: IndexSet, from projects: [Project], context: ModelContext) {
        for index in offset {
            let projetToDelete = projects[index]
            context.delete(projetToDelete)
        }
    }
}

//
//  Project.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 27.02.2026.
//

import Foundation
import SwiftData

@Model
class Project {
    var id: UUID
    var name: String
    var area: Double
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var materials: [Material] = []
    
    init(name: String, area: Double) {
        self.id = UUID()
        self.name = name
        self.area = area
        self.createdAt = Date()
    }
}

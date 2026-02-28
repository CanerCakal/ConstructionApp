//
//  Material.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 28.02.2026.
//

import Foundation
import SwiftData

@Model
class Material {
    var id: UUID
    var name: String
    var unit: String
    var userPerSquareMeter: Double
    var pricePerUnit: Double
    
    var project: Project?
    
    init(name: String, unit: String, userPerSquareMeter: Double, pricePerUnit: Double) {
        self.id = UUID()
        self.name = name
        self.unit = unit
        self.userPerSquareMeter = userPerSquareMeter
        self.pricePerUnit = pricePerUnit
    }
}

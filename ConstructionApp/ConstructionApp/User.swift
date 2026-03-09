//
//  User.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 2.03.2026.
//

import Foundation
import SwiftData

@Model
class User {
    
    @Relationship(deleteRule: .cascade, inverse: \Project.owner)
    var projects: [Project]? = []
    
    @Attribute(.unique) var email: String
    var passwordHash: String
    var salt: String
    
    init(email: String, passwordHash: String, salt: String) {
        self.email = email
        self.passwordHash = passwordHash
        self.salt = salt
    }
}

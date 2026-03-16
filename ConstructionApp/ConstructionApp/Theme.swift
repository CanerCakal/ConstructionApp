//
//  Theme.swift
//  ConstructionApp
//

import SwiftUI

enum Theme {
    // 1. Dinamik Arka Plan Renkleri (Petrol ve Gece Mavisi tonları - Cam efektini harika gösterir)
    static let bgStart = Color(red: 0.05, green: 0.16, blue: 0.24) // Derin Petrol Mavisi
    static let bgMid = Color(red: 0.10, green: 0.22, blue: 0.35)   // Modern Gece Mavisi
    static let bgEnd = Color(red: 0.03, green: 0.09, blue: 0.17)   // Çok Koyu Lacivert

    // 2. Vurgu Rengi (Kehribar / Parlak Altın - Koyu mavi üzerinde muazzam parlar ve dikkat çeker)
    static let accent = Color(red: 0.96, green: 0.65, blue: 0.14)
    
    // 3. Genel Metin Rengi
    static let text = Color.white
}

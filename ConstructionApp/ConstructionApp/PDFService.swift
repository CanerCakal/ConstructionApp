//
//  PDFService.swift
//  ConstructionApp
//
//  Created by Caner Çakal on 28.02.2026.
//

import Foundation
import UIKit
import PDFKit

class PDFService {
    static func generatePDF(for project: Project) -> URL? {
        let pdfMetaData = [kCGPDFContextCreator: "ConstructionApp",
                            kCGPDFContextAuthor: "Caner"]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0,
                                                            y: 0,
                                                            width: pageWidth,
                                                            height: pageHeight),
                                             format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 40
            
            let title = "Proje Raporu"
            title.draw(at: CGPoint(x: 40, y: yPosition),
                       withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
            yPosition += 40
            
            let projectInfo = """
                Proje Adı: \(project.name)
                Alan: \(project.area) m2
                """
            projectInfo.draw(at: CGPoint(x: 40, y: yPosition),
                             withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
            yPosition += 60
            
            for material in project.materials {
                let requiredAmount = project.area * material.userPerSquareMeter
                let totalPrice = requiredAmount * material.pricePerUnit
                
                let line = """
                    \(material.name)
                    Gerekli: \(requiredAmount) \(material.unit)
                    Toplam: \(totalPrice) TL
                    """
                
                line.draw(at: CGPoint(x: 40,
                                      y: yPosition),
                          withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                yPosition += 80
            }
            let total = "Genel Toplam: \(project.totalCost) TL"
            total.draw(at: CGPoint(x: 40,
                                   y: pageHeight - 80),
                       withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(project.name).pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Pdf oluşturulamadı")
            return nil
        }
    }
}

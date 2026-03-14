//
//  PDFService.swift
//  ConstructionApp
//
//  Created by Caner Çakal
//

import Foundation
import UIKit
import PDFKit

class PDFService {
    
    // A4 Sayfa Boyutları (Standart PDF)
    static let pageWidth: CGFloat = 595.2
    static let pageHeight: CGFloat = 841.8
    static let margin: CGFloat = 50.0
    
    static func generatePDF(for project: Project) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ConstructionApp",
            kCGPDFContextAuthor: "Construction Manager",
            kCGPDFContextTitle: "\(project.name) Maliyet Raporu"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            let cgContext = context.cgContext
            var yPosition: CGFloat = margin
            
            // 1. ÜST BİLGİ (HEADER) ÇİZİMİ
            drawHeader(yPosition: &yPosition)
            
            // 2. PROJE BİLGİLERİ
            drawProjectInfo(project: project, yPosition: &yPosition)
            
            // 3. TABLO BAŞLIĞI
            drawTableHeader(cgContext: cgContext, yPosition: &yPosition)
            
            // 4. MALZEME SATIRLARI
            for material in project.materials {
                // Eğer sayfanın sonuna yaklaştıysak yeni sayfa aç (Pagination)
                if yPosition > pageHeight - margin - 50 {
                    context.beginPage()
                    yPosition = margin
                    drawTableHeader(cgContext: cgContext, yPosition: &yPosition)
                }
                drawTableRow(material: material, projectArea: project.area, cgContext: cgContext, yPosition: &yPosition)
            }
            
            // 5. GENEL TOPLAM
            drawTotal(project: project, cgContext: cgContext, yPosition: &yPosition)
        }
        
        // PDF'i geçici klasöre kaydet
        let safeProjectName = project.name.replacingOccurrences(of: " ", with: "_")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeProjectName)_Raporu.pdf")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("PDF oluşturulamadı: \(error)")
            return nil
        }
    }
    
    // MARK: - YARDIMCI ÇİZİM FONKSİYONLARI
    
    private static func drawHeader(yPosition: inout CGFloat) {
        let title = "CONSTRUCTION MANAGER"
        let titleFont = UIFont.systemFont(ofSize: 22, weight: .black)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.systemBlue]
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
        
        let reportText = "Maliyet Analiz Raporu"
        let reportFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let reportAttributes: [NSAttributedString.Key: Any] = [.font: reportFont, .foregroundColor: UIColor.darkGray]
        reportText.draw(at: CGPoint(x: margin, y: yPosition + 28), withAttributes: reportAttributes)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateText = "Tarih: \(formatter.string(from: Date()))"
        let dateSize = dateText.size(withAttributes: reportAttributes)
        dateText.draw(at: CGPoint(x: pageWidth - margin - dateSize.width, y: yPosition + 28), withAttributes: reportAttributes)
        
        yPosition += 60
        drawLine(yPosition: yPosition)
        yPosition += 20
    }
    
    private static func drawProjectInfo(project: Project, yPosition: inout CGFloat) {
        let infoFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        let nameAttr = NSMutableAttributedString(string: "Proje Adı: ", attributes: [.font: boldFont])
        nameAttr.append(NSAttributedString(string: project.name, attributes: [.font: infoFont]))
        nameAttr.draw(at: CGPoint(x: margin, y: yPosition))
        
        let areaAttr = NSMutableAttributedString(string: "Toplam Alan: ", attributes: [.font: boldFont])
        areaAttr.append(NSAttributedString(string: "\(String(format: "%.2f", project.area)) m²", attributes: [.font: infoFont]))
        areaAttr.draw(at: CGPoint(x: margin, y: yPosition + 20))
        
        yPosition += 50
    }
    
    private static func drawTableHeader(cgContext: CGContext, yPosition: inout CGFloat) {
        // Tablo başlığı arka planı (Hafif Gri)
        cgContext.setFillColor(UIColor.systemGray6.cgColor)
        cgContext.fill(CGRect(x: margin, y: yPosition, width: pageWidth - (margin * 2), height: 30))
        
        let font = UIFont.systemFont(ofSize: 11, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        
        // Sütun Başlıkları ve X Koordinatları
        "MALZEME ADI".draw(at: CGPoint(x: margin + 10, y: yPosition + 8), withAttributes: attributes)
        "MİKTAR".draw(at: CGPoint(x: margin + 200, y: yPosition + 8), withAttributes: attributes)
        "BİRİM".draw(at: CGPoint(x: margin + 280, y: yPosition + 8), withAttributes: attributes)
        "B. FİYAT (₺)".draw(at: CGPoint(x: margin + 350, y: yPosition + 8), withAttributes: attributes)
        "TOPLAM (₺)".draw(at: CGPoint(x: margin + 430, y: yPosition + 8), withAttributes: attributes)
        
        yPosition += 30
        drawLine(yPosition: yPosition)
        yPosition += 10
    }
    
    private static func drawTableRow(material: Material, projectArea: Double, cgContext: CGContext, yPosition: inout CGFloat) {
        let requiredAmount = projectArea * material.userPerSquareMeter
        let totalPrice = requiredAmount * material.pricePerUnit
        
        let font = UIFont.systemFont(ofSize: 11, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.darkGray]
        
        material.name.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: attributes)
        String(format: "%.2f", requiredAmount).draw(at: CGPoint(x: margin + 200, y: yPosition), withAttributes: attributes)
        material.unit.draw(at: CGPoint(x: margin + 280, y: yPosition), withAttributes: attributes)
        String(format: "%.2f", material.pricePerUnit).draw(at: CGPoint(x: margin + 350, y: yPosition), withAttributes: attributes)
        String(format: "%.2f", totalPrice).draw(at: CGPoint(x: margin + 430, y: yPosition), withAttributes: attributes)
        
        yPosition += 25
        drawLine(yPosition: yPosition, isDashed: true)
        yPosition += 10
    }
    
    private static func drawTotal(project: Project, cgContext: CGContext, yPosition: inout CGFloat) {
        yPosition += 10
        drawLine(yPosition: yPosition)
        
        let font = UIFont.systemFont(ofSize: 14, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.systemRed]
        
        let totalText = "GENEL TOPLAM: \(String(format: "%.2f", project.totalCost)) ₺"
        let textSize = totalText.size(withAttributes: attributes)
        
        // Sağa yaslı yazdırmak için sayfa genişliğinden metin genişliğini çıkarıyoruz
        totalText.draw(at: CGPoint(x: pageWidth - margin - textSize.width - 10, y: yPosition + 15), withAttributes: attributes)
    }
    
    private static func drawLine(yPosition: CGFloat, isDashed: Bool = false) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: yPosition))
        path.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
        
        path.lineWidth = 1.0
        
        if isDashed {
            UIColor.systemGray5.setStroke()
            let dashes: [CGFloat] = [4.0, 2.0]
            path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        } else {
            UIColor.darkGray.setStroke()
        }
        
        path.stroke()
    }
}

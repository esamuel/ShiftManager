import Foundation
import PDFKit
import SwiftUI

protocol ExportServiceProtocol {
    func generatePDFReport(shifts: [ShiftModel], startDate: Date, endDate: Date) async throws -> Data
    func exportDataToJSON() async throws -> Data
    func importDataFromJSON(_ data: Data) async throws
    func generateSearchReport(shifts: [ShiftModel], username: String, periodString: String, summary: (totalDays: Int, totalHours: Double, grossWage: Double, netWage: Double)) async throws -> Data
}

class ExportService: ExportServiceProtocol {
    private let repository: ShiftRepositoryProtocol
    
    init(repository: ShiftRepositoryProtocol = ShiftRepository()) {
        self.repository = repository
    }
    
    func generatePDFReport(shifts: [ShiftModel], startDate: Date, endDate: Date) async throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "ShiftManager",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "Shift Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24.0)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]
            
            let title = "Shift Report"
            let titleStringSize = title.size(withAttributes: titleAttributes)
            let titleStringRect = CGRect(
                x: (pageRect.width - titleStringSize.width) / 2.0,
                y: 36,
                width: titleStringSize.width,
                height: titleStringSize.height
            )
            title.draw(in: titleStringRect, withAttributes: titleAttributes)
            
            // Date Range
            let dateFont = UIFont.systemFont(ofSize: 12.0)
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: dateFont
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
            let dateStringSize = dateString.size(withAttributes: dateAttributes)
            let dateStringRect = CGRect(
                x: (pageRect.width - dateStringSize.width) / 2.0,
                y: titleStringRect.maxY + 10,
                width: dateStringSize.width,
                height: dateStringSize.height
            )
            dateString.draw(in: dateStringRect, withAttributes: dateAttributes)
            
            // Summary Statistics
            var yPosition = dateStringRect.maxY + 20
            let summaryFont = UIFont.boldSystemFont(ofSize: 14.0)
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: summaryFont
            ]
            
            let totalShifts = shifts.count
            let totalHours = shifts.reduce(0) { $0 + $1.endTime.timeIntervalSince($1.startTime) } / 3600
            let overtimeShifts = shifts.filter { $0.isOvertime }.count
            
            let summaryText = "Total Shifts: \(totalShifts) | Total Hours: \(String(format: "%.1f", totalHours)) | Overtime Shifts: \(overtimeShifts)"
            let summaryStringSize = summaryText.size(withAttributes: summaryAttributes)
            let summaryStringRect = CGRect(
                x: 50,
                y: yPosition,
                width: summaryStringSize.width,
                height: summaryStringSize.height
            )
            summaryText.draw(in: summaryStringRect, withAttributes: summaryAttributes)
            
            // Shift Details
            yPosition = summaryStringRect.maxY + 20
            let shiftFont = UIFont.systemFont(ofSize: 12.0)
            let shiftAttributes: [NSAttributedString.Key: Any] = [
                .font: shiftFont
            ]
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            for shift in shifts {
                let duration = shift.endTime.timeIntervalSince(shift.startTime) / 3600
                let shiftText = "\(shift.title) - \(timeFormatter.string(from: shift.startTime)) to \(timeFormatter.string(from: shift.endTime)) (Duration: \(String(format: "%.1f", duration))h)"
                let shiftStringSize = shiftText.size(withAttributes: shiftAttributes)
                let shiftStringRect = CGRect(
                    x: 50,
                    y: yPosition,
                    width: shiftStringSize.width,
                    height: shiftStringSize.height
                )
                shiftText.draw(in: shiftStringRect, withAttributes: shiftAttributes)
                yPosition += shiftStringSize.height + 5
                
                if !shift.notes.isEmpty {
                    let notesText = "Notes: \(shift.notes)"
                    let notesStringSize = notesText.size(withAttributes: shiftAttributes)
                    let notesStringRect = CGRect(
                        x: 70,
                        y: yPosition,
                        width: notesStringSize.width,
                        height: notesStringSize.height
                    )
                    notesText.draw(in: notesStringRect, withAttributes: shiftAttributes)
                    yPosition += notesStringSize.height + 5
                }
            }
        }
    }
    
    func exportDataToJSON() async throws -> Data {
        let shifts = try await repository.fetchAllShifts()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(shifts)
    }
    
    func importDataFromJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let shifts = try decoder.decode([ShiftModel].self, from: data)
        
        // Clear existing data
        try await repository.deleteAllShifts()
        
        // Import new data
        for shift in shifts {
            try await repository.createShift(shift)
        }
    }
    
    func generateSearchReport(shifts: [ShiftModel], username: String, periodString: String, summary: (totalDays: Int, totalHours: Double, grossWage: Double, netWage: Double)) async throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "ShiftManager",
            kCGPDFContextAuthor: username,
            kCGPDFContextTitle: "Work Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Title attributes
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            
            // Header attributes
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            // Content attributes
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            // Draw title
            let title = "\(username)'s Work Report"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageRect.width - titleSize.width) / 2, y: 50), withAttributes: titleAttributes)
            
            // Draw period
            let period = "Period: \(periodString)"
            let periodSize = period.size(withAttributes: headerAttributes)
            period.draw(at: CGPoint(x: (pageRect.width - periodSize.width) / 2, y: 90), withAttributes: headerAttributes)
            
            // Table headers
            var yPosition: CGFloat = 130
            let xPositions: [CGFloat] = [50, 150, 250, 350, 450]
            let headers = ["Date", "Start Time", "End Time", "Hours", "Notes"]
            
            for (index, header) in headers.enumerated() {
                header.draw(at: CGPoint(x: xPositions[index], y: yPosition), withAttributes: headerAttributes)
            }
            
            yPosition += 30
            
            // Draw shifts
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            
            for shift in shifts {
                let date = dateFormatter.string(from: shift.startTime)
                let startTime = timeFormatter.string(from: shift.startTime)
                let endTime = timeFormatter.string(from: shift.endTime)
                let hours = String(format: "%.2f", shift.duration / 3600)
                
                date.draw(at: CGPoint(x: xPositions[0], y: yPosition), withAttributes: contentAttributes)
                startTime.draw(at: CGPoint(x: xPositions[1], y: yPosition), withAttributes: contentAttributes)
                endTime.draw(at: CGPoint(x: xPositions[2], y: yPosition), withAttributes: contentAttributes)
                hours.draw(at: CGPoint(x: xPositions[3], y: yPosition), withAttributes: contentAttributes)
                shift.notes.draw(at: CGPoint(x: xPositions[4], y: yPosition), withAttributes: contentAttributes)
                
                yPosition += 25
                
                // Start new page if needed
                if yPosition > pageRect.height - 100 {
                    context.beginPage()
                    yPosition = 50
                }
            }
            
            // Draw summary
            yPosition += 30
            let summaryTitle = "Summary"
            summaryTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            
            yPosition += 25
            let summaryItems = [
                "Total Working Days: \(summary.totalDays)",
                "Total Hours: \(String(format: "%.2f", summary.totalHours))",
                "Gross Wage: ₪\(String(format: "%.2f", summary.grossWage))",
                "Net Wage: ₪\(String(format: "%.2f", summary.netWage))"
            ]
            
            for item in summaryItems {
                item.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: contentAttributes)
                yPosition += 20
            }
        }
        
        return data
    }
} 
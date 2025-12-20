import Foundation
import PDFKit
import SwiftUI

protocol ExportServiceProtocol {
    func generatePDFReport(shifts: [ShiftModel], startDate: Date, endDate: Date) async throws -> Data
    func exportDataToJSON() async throws -> Data
    func importDataFromJSON(_ data: Data) async throws
    func generateSearchReport(shifts: [ShiftModel], username: String, periodString: String, summary: (totalDays: Int, totalHours: Double, grossWage: Double, netWage: Double)) async throws -> Data
    func generateMonthlyReport(shifts: [ShiftModel], month: Int, year: Int, username: String, summary: (totalShifts: Int, totalDays: Int, totalHours: Double, regularHours: Double, overtimeHours: Double, grossWage: Double, netWage: Double)) async throws -> Data
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
                let shiftText = "\(shift.displayTitle) - \(timeFormatter.string(from: shift.startTime)) to \(timeFormatter.string(from: shift.endTime)) (Duration: \(String(format: "%.1f", duration))h)"
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
            
            // Get currency symbol from LocalizationManager
            let currencySymbol = LocalizationManager.shared.currencySymbol
            
            let summaryItems = [
                "Total Working Days: \(summary.totalDays)",
                "Total Hours: \(String(format: "%.2f", summary.totalHours))",
                "Gross Wage: \(currencySymbol)\(String(format: "%.2f", summary.grossWage))",
                "Net Wage: \(currencySymbol)\(String(format: "%.2f", summary.netWage))"
            ]
            
            for item in summaryItems {
                item.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: contentAttributes)
                yPosition += 20
            }
        }
        
        return data
    }
    
    func generateMonthlyReport(shifts: [ShiftModel], month: Int, year: Int, username: String, summary: (totalShifts: Int, totalDays: Int, totalHours: Double, regularHours: Double, overtimeHours: Double, grossWage: Double, netWage: Double)) async throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "ShiftManager",
            kCGPDFContextAuthor: username,
            kCGPDFContextTitle: "Monthly Report".localized
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // Get properly localized month name using DateFormatter
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        monthDateFormatter.dateFormat = "MMMM" // Full month name
        
        var monthComponents = DateComponents()
        monthComponents.year = year
        monthComponents.month = month
        monthComponents.day = 1
        
        let monthDate = Calendar.current.date(from: monthComponents) ?? Date()
        let monthName = monthDateFormatter.string(from: monthDate)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Check if we're using an RTL language
            let isRTL = LocalizationManager.shared.currentLanguage == "he" || LocalizationManager.shared.currentLanguage == "ar"
            
            // Title attributes
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.systemPurple
            ]
            
            // Header attributes
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            
            // Content attributes
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            
            // Draw title
            let title = "Monthly Report".localized
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageRect.width - titleSize.width) / 2, y: 40), withAttributes: titleAttributes)
            
            // Draw username
            let usernameText = "\(username)'s \("Report Summary".localized)"
            let usernameSize = usernameText.size(withAttributes: headerAttributes)
            usernameText.draw(at: CGPoint(x: (pageRect.width - usernameSize.width) / 2, y: 80), withAttributes: headerAttributes)
            
            // Draw month and year
            let periodText = isRTL ? "\(year) \(monthName)" : "\(monthName) \(year)"
            let periodSize = periodText.size(withAttributes: headerAttributes)
            periodText.draw(at: CGPoint(x: (pageRect.width - periodSize.width) / 2, y: 110), withAttributes: headerAttributes)
            
            // Draw a separator line
            let separatorY: CGFloat = 140
            let separatorPath = UIBezierPath()
            separatorPath.move(to: CGPoint(x: 50, y: separatorY))
            separatorPath.addLine(to: CGPoint(x: pageRect.width - 50, y: separatorY))
            UIColor.systemPurple.setStroke()
            separatorPath.lineWidth = 2
            separatorPath.stroke()
            
            var yPosition: CGFloat = 170
            let leftMargin: CGFloat = 80
            let rightMargin: CGFloat = pageRect.width - 80
            
            // Get currency symbol
            let currencySymbol = LocalizationManager.shared.currencySymbol
            
            // Summary data with localized labels
            let summaryData: [(String, String)] = [
                ("Total Shifts:".localized, "\(summary.totalShifts)"),
                ("Total Working Days:".localized, "\(summary.totalDays)"),
                ("", ""), // Empty row for spacing
                ("Total Hours:".localized, String(format: "%.2f", summary.totalHours)),
                ("Regular Shift Hours:".localized, String(format: "%.2f", summary.regularHours)),
                ("Overtime Hours:".localized, String(format: "%.2f", summary.overtimeHours)),
                ("", ""), // Empty row for spacing
                ("Gross Wage:".localized, "\(currencySymbol)\(String(format: "%.2f", summary.grossWage))"),
                ("Net Wage:".localized, "\(currencySymbol)\(String(format: "%.2f", summary.netWage))")
            ]
            
            // Draw summary data
            for (label, value) in summaryData {
                if label.isEmpty {
                    // Add spacing
                    yPosition += 15
                    continue
                }
                
                if isRTL {
                    // For RTL, draw value on left, label on right
                    value.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: valueAttributes)
                    
                    let labelSize = label.size(withAttributes: contentAttributes)
                    label.draw(at: CGPoint(x: rightMargin - labelSize.width, y: yPosition), withAttributes: contentAttributes)
                } else {
                    // For LTR, draw label on left, value on right
                    label.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: contentAttributes)
                    
                    let valueSize = value.size(withAttributes: valueAttributes)
                    value.draw(at: CGPoint(x: rightMargin - valueSize.width, y: yPosition), withAttributes: valueAttributes)
                }
                
                yPosition += 30
            }
            
            // Add footer
            yPosition = pageRect.height - 60
            let separatorPath2 = UIBezierPath()
            separatorPath2.move(to: CGPoint(x: 50, y: yPosition - 20))
            separatorPath2.addLine(to: CGPoint(x: pageRect.width - 50, y: yPosition - 20))
            UIColor.systemGray.setStroke()
            separatorPath2.lineWidth = 1
            separatorPath2.stroke()
            
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let generatedDate = "Generated on".localized + " \(dateFormatter.string(from: Date()))"
            let footerSize = generatedDate.size(withAttributes: footerAttributes)
            generatedDate.draw(at: CGPoint(x: (pageRect.width - footerSize.width) / 2, y: yPosition), withAttributes: footerAttributes)
            
            let appName = "ShiftManager"
            let appNameSize = appName.size(withAttributes: footerAttributes)
            appName.draw(at: CGPoint(x: (pageRect.width - appNameSize.width) / 2, y: yPosition + 15), withAttributes: footerAttributes)
        }
        
        return data
    }
} 
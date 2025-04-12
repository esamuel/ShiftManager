import Foundation

struct PDFConfig: Codable {
    var companyName: String
    var companyAddress: String
    var includeLogo: Bool
    var logoURL: URL?
    var headerColor: String
    var fontName: String
    var fontSize: CGFloat
    
    init(companyName: String = "",
         companyAddress: String = "",
         includeLogo: Bool = false,
         logoURL: URL? = nil,
         headerColor: String = "#000000",
         fontName: String = "Helvetica",
         fontSize: CGFloat = 12.0) {
        self.companyName = companyName
        self.companyAddress = companyAddress
        self.includeLogo = includeLogo
        self.logoURL = logoURL
        self.headerColor = headerColor
        self.fontName = fontName
        self.fontSize = fontSize
    }
} 
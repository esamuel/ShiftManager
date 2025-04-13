import Foundation

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func asCurrency(value: Double) -> String {
        let formattedValue = String(format: "%.2f", value)
        let currencySymbol = LocalizationManager.shared.currencySymbol
        return "\(currencySymbol)\(formattedValue)"
    }
}

extension Double {
    var asCurrency: String {
        let formattedValue = String(format: "%.2f", self)
        let currencySymbol = LocalizationManager.shared.currencySymbol
        return "\(currencySymbol)\(formattedValue)"
    }
} 
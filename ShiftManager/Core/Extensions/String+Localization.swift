import Foundation

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func asCurrency(value: Double) -> String {
        return LocalizationManager.shared.formatCurrency(value)
    }
}

extension Double {
    var asCurrency: String {
        return LocalizationManager.shared.formatCurrency(self)
    }
} 
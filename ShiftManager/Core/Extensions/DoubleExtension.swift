import Foundation

extension Double {
    // asCurrency was removed to avoid conflict with implementation in String+Localization.swift
    
    func asFormattedString(decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.\(decimalPlaces)f", self)
    }
} 
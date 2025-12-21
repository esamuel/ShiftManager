import Foundation

extension String {
    func containsHebrewCharacters() -> Bool {
        // More comprehensive Hebrew character set including final letters
        let hebrewCharacterSet = CharacterSet(charactersIn: "אבגדהוזחטיכלמנסעפצקרשתךםןףץ")
        return self.rangeOfCharacter(from: hebrewCharacterSet) != nil
    }
    
    func isBackButtonText() -> Bool {
        // List of common back button texts in various languages
        let backTexts = [
            "Back", "back", "Previous", "previous",
            "חזרה", "חזור",
            "Назад", // Russian
            "Atrás", "Volver", // Spanish
            "Retour", // French
            "Zurück"  // German
        ]
        
        // Check for exact matches
        if backTexts.contains(self) {
            return true
        }
        
        return false
    }
} 
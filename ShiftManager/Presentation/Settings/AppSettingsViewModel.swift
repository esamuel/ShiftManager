import Foundation

public class AppSettingsViewModel: ObservableObject {
    @Published var username: String
    @Published var theme: String
    @Published var language: String
    
    public init() {
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        self.language = UserDefaults.standard.string(forKey: "language") ?? "en"
        
        setupObservers()
    }
    
    private func setupObservers() {
        self.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            UserDefaults.standard.set(self.username, forKey: "username")
            UserDefaults.standard.set(self.theme, forKey: "theme")
            UserDefaults.standard.set(self.language, forKey: "language")
        }
    }
} 
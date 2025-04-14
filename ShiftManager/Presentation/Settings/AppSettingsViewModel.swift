import Foundation
import Combine

public class AppSettingsViewModel: ObservableObject {
    @Published var username: String
    @Published var theme: String
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.theme = UserDefaults.standard.string(forKey: "theme") ?? "system"
        
        setupObservers()
    }
    
    private func setupObservers() {
        self.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            UserDefaults.standard.set(self.username, forKey: "username")
            UserDefaults.standard.set(self.theme, forKey: "theme")
        }
        .store(in: &cancellables)
    }
} 
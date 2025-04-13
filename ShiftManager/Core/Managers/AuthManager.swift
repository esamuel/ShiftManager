import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    private init() {
        // Initialize with default values
        self.isAuthenticated = false
        self.currentUser = nil
    }
    
    func signIn(email: String, password: String) async throws {
        // TODO: Implement actual authentication logic
        // For now, just simulate successful login
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.currentUser = User(id: "1", email: email, name: "Test User")
        }
    }
    
    func signOut() {
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
}

struct User {
    let id: String
    let email: String
    let name: String
} 
import Foundation
import StoreKit
import Combine

// MARK: - Product Identifiers
enum PremiumProduct: String, CaseIterable {
    case lifetime = "com.shiftmanager.premium.lifetime"
    case yearly = "com.shiftmanager.premium.yearly"
    case monthly = "com.shiftmanager.premium.monthly"
    
    var displayName: String {
        switch self {
        case .lifetime: return "Lifetime Access"
        case .yearly: return "Annual Subscription"
        case .monthly: return "Monthly Subscription"
        }
    }
    
    var description: String {
        switch self {
        case .lifetime: return "One-time payment, lifetime access to all premium features"
        case .yearly: return "All premium features, billed annually"
        case .monthly: return "All premium features, billed monthly"
        }
    }
}

// MARK: - Premium Features Enum
enum PremiumFeature {
    case pdfExport
    case advancedReports
    case splitShifts
    case unlimitedShifts
    case allLanguages
    case dataBackup
    case unlimitedHistory
    case multipleCurrencies
    case premiumThemes
    
    var displayName: String {
        switch self {
        case .pdfExport: return "PDF Export"
        case .advancedReports: return "Advanced Reports"
        case .splitShifts: return "Split Shifts"
        case .unlimitedShifts: return "Unlimited Shifts"
        case .allLanguages: return "All Languages"
        case .dataBackup: return "Data Backup & Restore"
        case .unlimitedHistory: return "Unlimited History"
        case .multipleCurrencies: return "Multiple Currencies"
        case .premiumThemes: return "Premium Themes"
        }
    }
    
    var icon: String {
        switch self {
        case .pdfExport: return "doc.fill"
        case .advancedReports: return "chart.bar.fill"
        case .splitShifts: return "rectangle.split.2x1.fill"
        case .unlimitedShifts: return "infinity"
        case .allLanguages: return "globe"
        case .dataBackup: return "icloud.fill"
        case .unlimitedHistory: return "calendar"
        case .multipleCurrencies: return "dollarsign.circle.fill"
        case .premiumThemes: return "paintpalette.fill"
        }
    }
}

// MARK: - Purchase Manager
@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published var showPaywall: Bool = false
    @Published private(set) var isRedeemed: Bool = false
    
    // Free tier limits
    private let freeShiftLimit = 50
    private let freeHistoryMonths = 3
    private let freeLanguageLimit = 2
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        // Load cached purchase status
        isRedeemed = UserDefaults.standard.bool(forKey: "isRedeemed")
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Feature Access Control
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        return isPremium
    }
    
    func canAddShift(currentCount: Int) -> Bool {
        if isPremium { return true }
        return currentCount < freeShiftLimit
    }
    
    func canAccessHistory(monthsAgo: Int) -> Bool {
        if isPremium { return true }
        return monthsAgo <= freeHistoryMonths
    }
    
    func canUseLanguage(languageCount: Int) -> Bool {
        if isPremium { return true }
        return languageCount <= freeLanguageLimit
    }
    
    func getRemainingFreeShifts(currentCount: Int) -> Int {
        if isPremium { return Int.max }
        return max(0, freeShiftLimit - currentCount)
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            let productIDs = PremiumProduct.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            print("✅ Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase Flow
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    func purchaseProduct(_ productType: PremiumProduct) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productType.rawValue }) else {
            throw PurchaseError.productNotFound
        }
        return try await purchase(product)
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Transaction Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        self.isPremium = !purchasedIDs.isEmpty || isRedeemed
        
        // Cache the premium status
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        
        print("✅ Premium status: \(isPremium)")
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                await transaction.finish()
                await self.updatePurchasedProducts()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func getProduct(for type: PremiumProduct) -> Product? {
        return products.first { $0.id == type.rawValue }
    }
    
    func getPriceString(for product: Product) -> String {
        return product.displayPrice
    }
    
    // For testing purposes
    #if DEBUG
    func simulatePremiumPurchase() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: "isPremium")
    }
    
    func resetPurchases() {
        isPremium = false
        isRedeemed = false
        purchasedProductIDs.removeAll()
        UserDefaults.standard.set(false, forKey: "isPremium")
        UserDefaults.standard.set(false, forKey: "isRedeemed")
    }
    #endif
    // MARK: - Promo Code Redemption
    
    func redeemCode(_ code: String) -> Bool {
        // Simple hardcoded codes for now. In a real app, this should check against a backend or hashed values.
        let validCodes = ["PREMIUM2025", "MANAGER_PRO", "SHIFT_MASTER"]
        
        if validCodes.contains(code.uppercased()) {
            isPremium = true
            isRedeemed = true
            UserDefaults.standard.set(true, forKey: "isPremium")
            UserDefaults.standard.set(true, forKey: "isRedeemed")
            return true
        }
        return false
    }
}

// MARK: - Purchase Errors
enum PurchaseError: LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}


import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var selectedProduct: PremiumProduct = .lifetime
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var showRedeemAlert = false
    @State private var redeemCode = ""
    
    var triggerFeature: PremiumFeature?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Feature List
                        featuresSection
                        
                        // Product Selection
                        productsSection
                        
                        // Purchase Button
                        purchaseButton
                        
                        // Restore Button
                        restoreButton
                        
                        // Redeem Code Button
                        redeemCodeButton
                        
                        // Terms and Privacy
                        legalSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Upgrade to Premium".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .alert("Success!".localized, isPresented: $showSuccess) {
                Button("OK".localized) {
                    dismiss()
                }
            } message: {
                Text("You now have access to all premium features!".localized)
            }
            .alert("Error".localized, isPresented: $showError) {
                Button("OK".localized, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
                    .sheet(isPresented: $showTerms) {
                        PremiumTermsView()
                    }
                    .sheet(isPresented: $showPrivacy) {
                        PremiumPrivacyView()
                    }
                    .alert("Enter Promo Code".localized, isPresented: $showRedeemAlert) {
                        TextField("Code", text: $redeemCode)
                            .autocapitalization(.allCharacters)
                        Button("Cancel".localized, role: .cancel) { }
                        Button("Redeem".localized) {
                            if purchaseManager.redeemCode(redeemCode) {
                                showSuccess = true
                            } else {
                                errorMessage = "Invalid Code".localized
                                showError = true
                            }
                            redeemCode = ""
                        }
                    } message: {
                        Text("Enter your code to unlock premium features.".localized)
                    }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Unlock Premium".localized)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Get unlimited access to all features".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Features".localized)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                FeatureRow(feature: .pdfExport)
                FeatureRow(feature: .advancedReports)
                FeatureRow(feature: .splitShifts)
                FeatureRow(feature: .unlimitedShifts)
                FeatureRow(feature: .allLanguages)
                FeatureRow(feature: .dataBackup)
                FeatureRow(feature: .unlimitedHistory)
                FeatureRow(feature: .multipleCurrencies)
                FeatureRow(feature: .premiumThemes)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Products Section
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Plan".localized)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Lifetime - Best Value
                ProductCard(
                    product: .lifetime,
                    isSelected: selectedProduct == .lifetime,
                    badge: "Best Value",
                    onTap: { selectedProduct = .lifetime }
                )
                
                // Yearly
                ProductCard(
                    product: .yearly,
                    isSelected: selectedProduct == .yearly,
                    badge: "Popular",
                    onTap: { selectedProduct = .yearly }
                )
                
                // Monthly
                ProductCard(
                    product: .monthly,
                    isSelected: selectedProduct == .monthly,
                    badge: nil,
                    onTap: { selectedProduct = .monthly }
                )
            }
        }
    }
    
    // MARK: - Purchase Button
    private var purchaseButton: some View {
        Button(action: {
            Task {
                await purchasePremium()
            }
        }) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "crown.fill")
                    Text("Continue".localized)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Restore Button
    private var restoreButton: some View {
        Button(action: {
            Task {
                await restorePurchases()
            }
        }) {
            Text("Restore Purchases".localized)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Redeem Code Button
    private var redeemCodeButton: some View {
        Button(action: {
            showRedeemAlert = true
        }) {
            Text("Redeem Code".localized)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("By purchasing, you agree to our Terms of Service and Privacy Policy".localized)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Terms of Service".localized) {
                    showTerms = true
                }
                .font(.caption2)
                
                Button("Privacy Policy".localized) {
                    showPrivacy = true
                }
                .font(.caption2)
            }
            .foregroundColor(.blue)
        }
        .padding(.bottom)
    }
    
    // MARK: - Purchase Logic
    private func purchasePremium() async {
        isPurchasing = true
        
        do {
            let success = try await purchaseManager.purchaseProduct(selectedProduct)
            
            await MainActor.run {
                isPurchasing = false
                if success {
                    showSuccess = true
                }
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        
        do {
            try await purchaseManager.restorePurchases()
            
            await MainActor.run {
                isPurchasing = false
                if purchaseManager.isPremium {
                    showSuccess = true
                } else {
                    errorMessage = "No previous purchases found".localized
                    showError = true
                }
            }
        } catch {
            await MainActor.run {
                isPurchasing = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(feature.displayName.localized)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: PremiumProduct
    let isSelected: Bool
    let badge: String?
    let onTap: () -> Void
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.displayName.localized)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let badge = badge {
                                Text(badge.localized)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(product.description.localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let storeProduct = purchaseManager.getProduct(for: product) {
                        Text(storeProduct.displayPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
                
                // Savings indicator for yearly
                if product == .yearly, 
                   let yearlyProduct = purchaseManager.getProduct(for: .yearly),
                   let monthlyProduct = purchaseManager.getProduct(for: .monthly) {
                    
                    if let yearlyPrice = yearlyProduct.price as? Decimal,
                       let monthlyPrice = monthlyProduct.price as? Decimal {
                        let yearlyValue = NSDecimalNumber(decimal: yearlyPrice).doubleValue
                        let monthlyValue = NSDecimalNumber(decimal: monthlyPrice).doubleValue
                        let savings = ((monthlyValue * 12) - yearlyValue) / (monthlyValue * 12) * 100
                        
                        if savings > 0 {
                            Text("Save \(Int(savings))%".localized)
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    PaywallView()
}


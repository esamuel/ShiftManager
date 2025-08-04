import SwiftUI

struct OnboardingView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @Binding var isShowingOnboarding: Bool
    @State private var currentPage = 0
    @State private var showingQuickStart = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to ShiftManager".localized,
            description: "Your personal work shift tracker with wage calculation and reporting features.".localized,
            imageName: "hand.wave.fill"
        ),
        OnboardingPage(
            title: "Track Your Shifts".localized,
            description: "Add, edit, and manage your work shifts. Mark special days and track overtime automatically.".localized,
            imageName: "calendar"
        ),
        OnboardingPage(
            title: "Customize Overtime Rules".localized,
            description: "Set your own overtime rules with different rates for regular and special days.".localized,
            imageName: "clock.fill"
        ),
        OnboardingPage(
            title: "View Detailed Reports".localized,
            description: "See your earnings and hours worked with detailed breakdowns for regular and overtime hours.".localized,
            imageName: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Get Started".localized,
            description: "Configure your basic settings now to personalize your experience, or do it later in the Settings menu.".localized,
            imageName: "gearshape.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip".localized) {
                        withAnimation {
                            showingQuickStart = true
                        }
                    }
                    .padding()
                    .foregroundColor(.purple)
                }
                
                // Paging view with dots
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(systemName: pages[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.purple)
                                .padding(.bottom, 30)
                            
                            Text(pages[index].title)
                                .font(.system(size: 32, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(pages[index].description)
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .foregroundColor(.secondary)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                            }
                            .foregroundColor(.purple)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                    } else {
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                showingQuickStart = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Next".localized : "Get Started".localized)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .refreshOnLanguageChange()
        .fullScreenCover(isPresented: $showingQuickStart) {
            QuickStartView(isShowingQuickStart: $showingQuickStart)
                .onDisappear {
                    // End onboarding when quick start is dismissed
                    isShowingOnboarding = false
                }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView(isShowingOnboarding: .constant(true))
} 
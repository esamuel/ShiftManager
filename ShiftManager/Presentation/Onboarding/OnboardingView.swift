import SwiftUI

struct OnboardingView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @Binding var isShowingOnboarding: Bool
    @State private var currentPage = 0
    @State private var showingQuickStart = false
    @Environment(\.verticalSizeClass) var verticalSizeClass

    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to ShiftManager".localized,
            description: "Your personal work shift tracker with wage calculation and reporting features.".localized,
            imageName: "AppLogo"
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
                        contentView(for: pages[index], isFirstPage: index == 0)
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
    
    @ViewBuilder
    private func contentView(for page: OnboardingPage, isFirstPage: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            if verticalSizeClass == .compact {
                // Landscape: Side-by-side
                HStack(alignment: .center, spacing: 30) {
                    imageView(for: page.imageName)
                        .frame(maxWidth: 300)
                    
                    VStack(alignment: .center, spacing: 15) {
                        Text(page.title)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(page.description)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        if isFirstPage {
                            VideoTutorialButton(
                                title: "Watch: App Overview".localized,
                                videoURL: URL(string: "https://www.youtube.com/watch?v=placeholder_overview")!
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            } else {
                // Portrait: Vertical Stack
                VStack(spacing: 20) {
                    imageView(for: page.imageName)
                        .frame(height: 240)
                    
                    Text(page.title)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(page.description)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .foregroundColor(.secondary)
                    
                    if isFirstPage {
                        VideoTutorialButton(
                            title: "Watch: App Overview".localized,
                            videoURL: URL(string: "https://www.youtube.com/watch?v=placeholder_overview")!
                        )
                        .padding(.top, 10)
                    }
                }
                .padding(.top, 40)
            }
        }
    }
    
    @ViewBuilder
    private func imageView(for imageName: String) -> some View {
        if imageName == "AppLogo" {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .flipsForRightToLeftLayoutDirection(false)
        } else {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.purple)
                .padding(.vertical, 40)
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
import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingUpcomingShifts = false
    @State private var showingGuide = false
    @State private var showingAISupport = false
    @State private var activeDestination: HomeDestination?
    
    private enum HomeDestination: Hashable {
        case shiftManager
        case reports
        case guide
        case overtimeRules
        case settings
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title
                HStack {
                    Text("Shift Manager".localized)
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                    
                    // Help button
                    Button(action: {
                        showingGuide = true
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundColor(.purple)
                            .padding(6)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Help".localized)
                    .help("Open User Guide".localized)
                }
                .padding(.top, 4)
                .padding(.horizontal)
                .padding(.bottom, 0)
                
                // Hidden navigation links
                navigationLinks
                
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
                
                // Menu Buttons
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) { // Reduced spacing
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                            // Home Button (Main Screen)
                            Button(action: { showingUpcomingShifts = true }) {
                                GridMenuButton(
                                    title: "Coming Shifts".localized,
                                    icon: "house.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                            
                            Button(action: { navigate(to: .shiftManager) }) {
                                GridMenuButton(
                                    title: "Shift Manager".localized,
                                    icon: "briefcase.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                            
                            Button(action: { navigate(to: .reports) }) {
                                GridMenuButton(
                                    title: "Reports".localized,
                                    icon: "chart.bar.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                            
                            Button(action: { navigate(to: .guide) }) {
                                GridMenuButton(
                                    title: "Guide".localized,
                                    icon: "info.circle.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                            
                            Button(action: { navigate(to: .overtimeRules) }) {
                                GridMenuButton(
                                    title: "Overtime Rules".localized,
                                    icon: "clock.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                            
                            Button(action: { navigate(to: .settings) }) {
                                GridMenuButton(
                                    title: "Settings".localized,
                                    icon: "gearshape.fill",
                                    color: Color(red: 0.8, green: 0.7, blue: 1.0)
                                )
                            }
                        }
                        
                        // AI Support Agent (Full Width)
                        Button(action: { showingAISupport = true }) {
                            MenuButton(
                                title: "AI Support Agent".localized,
                                icon: "brain.head.profile",
                                color: .purple
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .fullScreenCover(isPresented: $showingUpcomingShifts) {
            NavigationView {
                UpcomingShiftsView()
                    .navigationTitle("Upcoming Shifts".localized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done".localized) {
                                showingUpcomingShifts = false
                            }
                            .foregroundColor(.purple)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingGuide) {
            GuideView()
        }
        .fullScreenCover(isPresented: $showingAISupport) {
            VoiceAISupportView()
        }
        .refreshOnLanguageChange()
    }
    
    @ViewBuilder
    private var navigationLinks: some View {
        Group {
            NavigationLink(
                destination: destinationView(for: .shiftManager),
                tag: .shiftManager,
                selection: $activeDestination
            ) { EmptyView() }
            
            NavigationLink(
                destination: destinationView(for: .reports),
                tag: .reports,
                selection: $activeDestination
            ) { EmptyView() }
            
            NavigationLink(
                destination: destinationView(for: .guide),
                tag: .guide,
                selection: $activeDestination
            ) { EmptyView() }
            
            NavigationLink(
                destination: destinationView(for: .overtimeRules),
                tag: .overtimeRules,
                selection: $activeDestination
            ) { EmptyView() }
            
            NavigationLink(
                destination: destinationView(for: .settings),
                tag: .settings,
                selection: $activeDestination
            ) { EmptyView() }
        }
        .hidden()
    }
    
    @ViewBuilder
    private func destinationView(for destination: HomeDestination) -> some View {
        switch destination {
        case .shiftManager:
            ShiftManagerView()
        case .reports:
            ReportView()
        case .guide:
            GuideView()
        case .overtimeRules:
            OvertimeRulesView()
        case .settings:
            SettingsView()
        }
    }
    
    private func navigate(to destination: HomeDestination) {
        activeDestination = destination
    }
}

public struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    public init(title: String, icon: String, color: Color) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        let isRTL = LocalizationManager.shared.currentLanguage == "he" || LocalizationManager.shared.currentLanguage == "ar"
        
        HStack(spacing: 10) {
            if isRTL {
                // For RTL: chevron on left, then spacer, then text, then icon
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .font(.system(size: 13, weight: .semibold))
                
                Spacer(minLength: 6)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .clipShape(Circle())
            } else {
                // For LTR: icon, then text, then spacer, then chevron
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 6)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(color.opacity(0.2))
        .cornerRadius(12)
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }
}

public struct GridMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    public init(title: String, icon: String, color: Color) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(color.opacity(0.2))
        .cornerRadius(16)
    }
}

#Preview {
    HomeView()
} 
import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingUpcomingShifts = false
    @State private var showingGuide = false
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
            VStack(spacing: 8) {
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
                .padding(.top, 8)
                .padding(.horizontal)
                
                // Hidden navigation links
                navigationLinks
                
                // Menu Buttons
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Home Button (Main Screen)
                        Button(action: { showingUpcomingShifts = true }) {
                            MenuButton(
                                title: "Coming Shifts".localized,
                                icon: "house.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        Button(action: { navigate(to: .shiftManager) }) {
                            MenuButton(
                                title: "Shift Manager".localized,
                                icon: "briefcase.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        Button(action: { navigate(to: .reports) }) {
                            MenuButton(
                                title: "Reports".localized,
                                icon: "chart.bar.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        Button(action: { navigate(to: .guide) }) {
                            MenuButton(
                                title: "Guide".localized,
                                icon: "info.circle.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        Button(action: { navigate(to: .overtimeRules) }) {
                            MenuButton(
                                title: "Overtime Rules".localized,
                                icon: "clock.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
                            )
                        }
                        
                        Button(action: { navigate(to: .settings) }) {
                            MenuButton(
                                title: "Settings".localized,
                                icon: "gearshape.fill",
                                color: Color(red: 0.8, green: 0.7, blue: 1.0)
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

#Preview {
    HomeView()
} 
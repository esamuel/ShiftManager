import Foundation

struct Tutorial: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: URL
    
    static let allTutorials: [Tutorial] = [
        Tutorial(
            title: "App Overview".localized,
            description: "A quick tour of ShiftManager's main features.".localized,
            url: URL(string: "https://www.youtube.com/watch?v=placeholder_overview")!
        ),
        Tutorial(
            title: "Initial Setup".localized,
            description: "Learn how to set up your profile and wage settings.".localized,
            url: URL(string: "https://www.youtube.com/watch?v=placeholder_setup")!
        ),
        Tutorial(
            title: "Overtime Rules".localized,
            description: "Configure overtime rules to match your workplace.".localized,
            url: URL(string: "https://www.youtube.com/watch?v=placeholder_overtime")!
        ),
        Tutorial(
            title: "Managing Shifts".localized,
            description: "How to add, edit, and manage your shifts.".localized,
            url: URL(string: "https://www.youtube.com/watch?v=placeholder_shifts")!
        ),
        Tutorial(
            title: "Reports & Export".localized,
            description: "Generate reports and export your data.".localized,
            url: URL(string: "https://www.youtube.com/watch?v=placeholder_reports")!
        )
    ]
}

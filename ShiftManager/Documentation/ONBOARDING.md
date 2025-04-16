# ShiftManager Onboarding Guide

## Welcome to ShiftManager!

This guide will help you get started with the ShiftManager project. It covers everything from setting up your development environment to understanding the codebase structure and development workflow.

## Prerequisites

### Development Environment
- macOS (latest version recommended)
- Xcode 13.0 or later
- iOS 15.0 or later
- Git

### Required Knowledge
- Swift 5.5+
- SwiftUI
- CoreData
- Combine Framework
- MVVM Architecture

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/esamuel/ShiftManager.git
cd ShiftManager
```

### 2. Open the Project
```bash
open ShiftManager.xcodeproj
```

### 3. Build and Run
- Select your target device/simulator
- Press Cmd+R to build and run the project

## Project Structure

### Directory Organization
```
ShiftManager/
├── Application/          # App lifecycle and configuration
├── Core/                # Core utilities and managers
├── Data/                # Data layer (CoreData, repositories)
├── Domain/              # Business logic and models
├── Presentation/        # UI layer (SwiftUI views)
├── Resources/           # Assets, localization files
└── Services/            # Business services
```

### Key Files
- `AppDelegate.swift`: Application lifecycle management
- `StyleGuide.swift`: UI styling and theming
- `LocalizationManager.swift`: Language and localization handling
- `PersistenceController.swift`: CoreData setup and management

## Development Guidelines

### Code Style
- Follow Swift style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

### Architecture
- Follow MVVM pattern
- Keep business logic in ViewModels
- Use Combine for reactive programming
- Maintain clean separation of concerns

### UI Development
- Use SwiftUI for new views
- Follow StyleGuide for consistent UI
- Support dark mode
- Ensure RTL support for Hebrew

### Data Management
- Use CoreData for persistence
- Follow repository pattern
- Implement proper error handling
- Maintain data consistency

## Common Tasks

### Adding a New Feature
1. Create necessary models in Domain layer
2. Implement repository methods
3. Create ViewModel
4. Design SwiftUI view
5. Add tests
6. Update documentation

### Localization
1. Add new strings to Localizable.strings
2. Update LocalizationManager if needed
3. Test in all supported languages
4. Verify RTL support for Hebrew

### Debugging
- Use Xcode debugger
- Check CoreData stack
- Monitor memory usage
- Test edge cases

## Testing

### Unit Tests
- Test ViewModels
- Test services
- Test utilities
- Test data models

### UI Tests
- Test navigation flow
- Test user interactions
- Test data persistence
- Test localization

## Deployment

### Build Process
1. Update version number
2. Run tests
3. Build for release
4. Archive and upload

### App Store Submission
1. Prepare screenshots
2. Write release notes
3. Submit for review
4. Monitor crash reports

## Troubleshooting

### Common Issues
1. CoreData migration problems
2. Localization issues
3. Navigation bugs
4. Performance problems

### Solutions
- Check CoreData model version
- Verify localization files
- Review navigation stack
- Profile app performance

## Resources

### Documentation
- [Technical Design Document](TECHNICAL_DESIGN.md)
- [API Documentation](API.md)
- [Style Guide](STYLE_GUIDE.md)

### External Resources
- [Swift Documentation](https://docs.swift.org)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [CoreData Guide](https://developer.apple.com/documentation/coredata)

## Support

### Getting Help
- Check documentation
- Ask team members
- Review code comments
- Search issue tracker

### Reporting Issues
1. Check existing issues
2. Create new issue
3. Provide detailed information
4. Include reproduction steps

## Next Steps

### Learning Path
1. Review codebase structure
2. Study key components
3. Work on small tasks
4. Take on larger features

### Contribution Guidelines
- Follow coding standards
- Write tests
- Update documentation
- Get code review

## Contact

### Team Members
- Project Lead: [Name]
- Technical Lead: [Name]
- UI/UX Lead: [Name]

### Communication
- Slack Channel: #shiftmanager
- Email: dev@shiftmanager.app
- Weekly Meetings: [Schedule] 
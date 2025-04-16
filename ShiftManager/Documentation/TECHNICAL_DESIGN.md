# ShiftManager Technical Design Document

## Overview
ShiftManager is a modern iOS application built with SwiftUI and CoreData, designed to help users track work shifts, calculate wages, and manage overtime. The app follows the MVVM (Model-View-ViewModel) architecture pattern and incorporates best practices for iOS development.

## Architecture

### Core Components
1. **Presentation Layer**
   - SwiftUI Views
   - ViewModels
   - Navigation Controllers
   - Custom UI Components

2. **Domain Layer**
   - Models
   - Business Logic
   - Use Cases
   - Data Transfer Objects

3. **Data Layer**
   - CoreData Persistence
   - Repositories
   - Services
   - Local Storage

4. **Core Layer**
   - Utilities
   - Managers
   - Extensions
   - Constants

### Key Design Patterns
- MVVM Architecture
- Repository Pattern
- Singleton Pattern (for managers)
- Factory Pattern (for services)
- Observer Pattern (using Combine)

## Technical Stack

### Core Technologies
- Swift 5.5+
- iOS 15.0+
- SwiftUI
- CoreData
- Combine Framework

### Key Frameworks
- UIKit (for legacy support)
- CoreData (for persistence)
- Combine (for reactive programming)
- SwiftUI (for modern UI)

## Data Management

### CoreData Model
The app uses CoreData for local persistence with the following entities:

1. **Shift**
   - Basic shift information (start/end times)
   - Wage calculations
   - Categories and notes
   - Overtime flags

2. **OvertimeRule**
   - Daily/weekly thresholds
   - Multiplier rates
   - Active status

3. **Settings**
   - User preferences
   - Default configurations
   - Language settings

### Data Flow
1. User input → ViewModel → Repository
2. Repository → CoreData → Local Storage
3. Local Storage → Repository → ViewModel → View

## UI/UX Design

### Style Guide
The app maintains consistent styling through a centralized `StyleGuide`:

- **Spacing Constants**
  - Small: 8.0
  - Medium: 16.0
  - Large: 24.0

- **Typography**
  - Title Font: System, 20pt, Semibold
  - Body Font: System, 16pt, Regular
  - Caption Font: System, 12pt, Regular

- **Color Palette**
  - Primary Text (supports dark mode)
  - Secondary Text (supports dark mode)
  - Background (supports dark mode)
  - Accent Color (system blue)

### Navigation
- Custom navigation bar configuration
- Symbol-only back buttons
- Support for multiple languages
- RTL support for Hebrew

## Localization

### Supported Languages
- English
- Hebrew
- Russian
- Spanish
- French
- German

### Localization Manager
- Handles language switching
- Manages string translations
- Supports RTL layouts
- Maintains currency formats

## Security

### Data Protection
- Local storage only
- No external server communication
- Optional cloud backup
- User data privacy

### Authentication
- Local authentication
- Biometric support
- Secure data storage

## Performance Considerations

### Memory Management
- Efficient CoreData usage
- Proper view lifecycle management
- Background task optimization

### UI Performance
- Lazy loading of views
- Efficient data fetching
- Proper state management

## Testing Strategy

### Unit Tests
- ViewModel tests
- Service tests
- Manager tests

### UI Tests
- Navigation flow
- User interactions
- Data persistence

## Deployment

### Requirements
- Xcode 13.0+
- iOS 15.0+
- Swift 5.5+

### Build Configuration
- Debug
- Release
- TestFlight

## Future Considerations

### Planned Features
- Cloud synchronization
- Advanced reporting
- Team management
- API integration

### Technical Debt
- Legacy UIKit components
- Complex navigation logic
- Localization challenges

## Support and Maintenance

### Error Handling
- Graceful degradation
- User-friendly error messages
- Crash reporting

### Updates
- Regular maintenance
- Feature updates
- Bug fixes

## Documentation

### Code Documentation
- Inline comments
- API documentation
- Architecture diagrams

### User Documentation
- User guides
- FAQ
- Support resources 
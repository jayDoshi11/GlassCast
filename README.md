# GlassCast 🌤️

A minimal, elegant weather application built with SwiftUI featuring iOS 26 Liquid Glass design and AI-first development practices.

![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)
![Supabase](https://img.shields.io/badge/Supabase-Backend-brightgreen.svg)

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Design Philosophy](#design-philosophy)
- [Technical Stack](#technical-stack)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [AI-Assisted Development](#ai-assisted-development)
- [Project Structure](#project-structure)
- [API Configuration](#api-configuration)
- [Screenshots](#screenshots)
- [Development Workflow](#development-workflow)
- [Evaluation Criteria](#evaluation-criteria)
- [Bonus Features](#bonus-features)
- [Resources](#resources)
- [License](#license)

## 🎯 About

GlassCast is a weather application developed as part of an iOS developer remote job interview assignment. The project showcases modern iOS development practices, AI-assisted coding workflows, and the implementation of iOS 26's Liquid Glass design system.

**Time Allocation:** 2-3 days  
**Platform:** SwiftUI (iOS 26+)  
**Development Approach:** AI-First using Claude Code or Cursor

## ✨ Features

### Core Features

#### 🔐 Authentication Screen
- Email/password authentication via Supabase
- Clean, minimal UI with Liquid Glass effects
- Secure credential management
- Sign up and login flows

#### 🏠 Home Screen
- Current weather display for selected city
- Temperature with condition icons
- High/Low temperature indicators
- 5-day forecast cards with glass morphism
- Pull-to-refresh functionality
- Smooth animations and transitions

#### 🔍 City Search
- Real-time city search with autocomplete
- Add cities to favorites
- Synced to user account via Supabase
- Beautiful search results with glass containers

#### ⚙️ Settings
- Temperature unit toggle (°C/°F)
- User preferences persistence
- Sign out functionality
- Clean settings interface

## 🎨 Design Philosophy

### iOS 26 Liquid Glass Implementation

This app leverages iOS 26's revolutionary Liquid Glass design system:  

- **`.glassEffect()`** - Native SwiftUI glass effect modifier
- **`GlassEffectContainer`** - Container views with depth and translucency
- **Glass-based navigation** - Tab bars and navigation with glass aesthetics
- **Blur and translucency** - Layered visual hierarchy
- **Depth perception** - Subtle shadows and lighting effects
- **Smooth animations** - Fluid transitions between states

### Design Tools Used

The app design was created using:
- **Google Stitch** (Primary) - AI-powered design generation
- **Figma Make** (Alternative) - AI-assisted design prototyping

## 🛠 Technical Stack

| Component | Technology |
|-----------|-----------|
| **Frontend** | SwiftUI (iOS 26+) |
| **Language** | Swift 6.0+ |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Backend** | Supabase (Auth + Database) |
| **Weather API** | OpenWeatherMap / WeatherAPI / Tomorrow.io |
| **AI Tools** | Claude Code / Cursor |
| **Version Control** | Git / GitHub |

## 🏗 Architecture

### MVVM Pattern

The project follows MVVM architecture with clear separation of concerns:

- **Models** - Data structures (User, Weather, City, ForecastDay)
- **Views** - SwiftUI views with Liquid Glass UI components
- **ViewModels** - Business logic and state management
- **Services** - API integration (Supabase, Weather API, Location)
- **Utilities** - Helpers, extensions, and reusable components

## 🚀 Setup Instructions

### Prerequisites

- macOS 15.0+ (Sequoia or later)
- Xcode 18.0+ with iOS 26 SDK
- iOS 26.0+ device or simulator
- Active internet connection
- Supabase account (free tier)
- Weather API key (OpenWeatherMap, etc.)

### Step 1: Clone the Repository

```bash
git clone https://github.com/jayDoshi11/GlassCast.git
cd GlassCast
```

### Step 2: Install Dependencies

This project uses Swift Package Manager (SPM). Dependencies should be automatically resolved by Xcode.

**Required Packages:**
- Supabase Swift SDK
- Alamofire (optional, for networking)

### Step 3: Configure Supabase

1. **Create a Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project (free tier)
   - Note your project URL and anon key

2. **Create the Database Table**

```sql
-- Create favorite_cities table
CREATE TABLE favorite_cities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    city_name TEXT NOT NULL,
    lat DECIMAL(10, 8) NOT NULL,
    lon DECIMAL(11, 8) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE favorite_cities ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own favorite cities"
    ON favorite_cities FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own favorite cities"
    ON favorite_cities FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own favorite cities"
    ON favorite_cities FOR DELETE
    USING (auth.uid() = user_id);
```

3. **Enable Authentication**
   - Navigate to Authentication → Settings
   - Enable Email provider
   - Configure email templates (optional)

### Step 4: Configure Environment Variables

Create a `Config.swift` file in the project:  

```swift
// Config.swift
import Foundation

enum Config {
    // Supabase Configuration
    static let supabaseURL = "YOUR_SUPABASE_PROJECT_URL"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    // Weather API Configuration
    static let weatherAPIKey = "YOUR_WEATHER_API_KEY"
    static let weatherAPIBaseURL = "https://api.openweathermap.org/data/2.5"
}
```

**⚠️ Security Note:** Never commit API keys to version control. Use `.gitignore`:

```gitignore
# . gitignore
Config.swift
*. xcuserdata
. DS_Store
```

**Alternative: Use Xcode Configuration Files**

Create `Config.xcconfig`:

```
SUPABASE_URL = your_supabase_url
SUPABASE_ANON_KEY = your_supabase_key
WEATHER_API_KEY = your_weather_api_key
```

### Step 5: Get Weather API Key

**Option 1: OpenWeatherMap**
1. Sign up at [openweathermap. org](https://openweathermap.org/api)
2. Get free API key
3. Add to `Config.swift`

**Option 2: WeatherAPI**
1. Sign up at [weatherapi.com](https://www.weatherapi.com/)
2. Get free API key (more generous limits)

**Option 3: Tomorrow.io**
1. Sign up at [tomorrow.io](https://www.tomorrow.io/)
2. Get free tier API key

### Step 6: Build and Run

1. Open `GlassCast.xcodeproj` in Xcode
2. Select iOS 26 Simulator or physical device
3. Build and run (⌘ + R)

## 🤖 AI-Assisted Development

This project was developed using AI-first methodologies with Claude Code or Cursor as the primary development environment.

### CLAUDE.md Context File

The project includes a `CLAUDE.md` file that provides context to the AI assistant:

```markdown
# GlassCast AI Context

## Project Overview
iOS weather app using SwiftUI with iOS 26 Liquid Glass design. 

## Tech Stack
- SwiftUI with iOS 26 features
- Supabase for auth and database
- MVVM architecture pattern
- Weather API integration

## Design Guidelines
- Use . glassEffect() for all card components
- Implement GlassEffectContainer for main views
- Smooth animations (spring, easeInOut)
- SF Symbols for icons

## Code Standards
- Follow Swift API Design Guidelines
- Use async/await for networking
- Handle errors gracefully with proper user feedback
- Write self-documenting code with comments for complex logic
```

### AI Workflow Demonstration

A screen recording (15-30 minutes) demonstrates: 
- **Effective prompting** - How to communicate requirements to AI
- **Iterative development** - Building features step-by-step
- **Debugging with AI** - Problem-solving and error resolution
- **Handling AI limitations** - When to guide vs. let AI lead
- **Code refinement** - Improving AI-generated code

### Example AI Prompts Used

```
"Create a WeatherCardView in SwiftUI using iOS 26 GlassEffectContainer 
with temperature, condition icon, and high/low temps"

"Implement pull-to-refresh in HomeView that fetches latest weather data 
with proper error handling and loading states"

"Add Supabase authentication with email/password, include input validation 
and secure credential storage"
```

## 📁 Project Structure

```
GlassCast/
├── . gitignore
├── README. md
├── CLAUDE.md
├── LICENSE
├── GlassCast.xcodeproj
│
├── ───��─────────── App Files ───────────────
├── GlassCastApp.swift              # Main app entry point
├── ContentView.swift                # Root content view
│
├── ─────────────── Models ───────────────
├── User.swift                       # User data model
├── Weather.swift                    # Current weather model
├── City.swift                       # City data model
├── ForecastDay.swift                # Forecast data model
│
├── ─────────────── Views ───────────────
│   # Authentication Views
├── LoginView.swift                  # Login screen
├── SignUpView.swift                 # Sign up screen
│
│   # Home Views
├── HomeView.swift                   # Main weather screen
├── WeatherCardView.swift            # Current weather card
├── ForecastCardView.swift           # Forecast card component
│
│   # Search Views
├── CitySearchView.swift             # City search screen
├── SearchResultRow.swift            # Search result item
│
│   # Settings Views
├── SettingsView. swift               # Settings screen
│
├── ─────────────── ViewModels ───────────────
├── AuthViewModel.swift              # Authentication logic
├── WeatherViewModel.swift           # Weather data logic
├── CitySearchViewModel.swift        # Search logic
├── SettingsViewModel.swift          # Settings logic
│
├── ─────────────── Services ───────────────
├── SupabaseService.swift            # Supabase integration
├── WeatherService.swift             # Weather API integration
├── LocationService.swift            # Location services
│
├── ─────────────── Utilities ───────────────
├── Constants.swift                  # App constants
├── Extensions.swift                 # Swift extensions
├── GlassEffectModifiers.swift       # Custom glass modifiers
├── Config.swift                     # API configuration (gitignored)
│
└── ─────────────── Resources ───────────────
    └── Assets.xcassets              # Images, colors, assets
```

### File Organization

Since all files are in the root directory due to git issues, the files are organized by their functional purpose:

**App Layer:**
- `GlassCastApp.swift` - App lifecycle and initialization
- `ContentView.swift` - Root view with navigation

**Models Layer:**
- `User.swift`, `Weather.swift`, `City.swift`, `ForecastDay.swift` - Data structures

**Views Layer:**
- Authentication:  `LoginView.swift`, `SignUpView.swift`
- Home: `HomeView.swift`, `WeatherCardView.swift`, `ForecastCardView.swift`
- Search: `CitySearchView.swift`, `SearchResultRow.swift`
- Settings: `SettingsView.swift`

**ViewModels Layer:**
- `AuthViewModel.swift` - Handles authentication state and logic
- `WeatherViewModel.swift` - Manages weather data fetching and state
- `CitySearchViewModel.swift` - Handles search and favorites
- `SettingsViewModel.swift` - Manages user preferences

**Services Layer:**
- `SupabaseService.swift` - Supabase client and database operations
- `WeatherService.swift` - Weather API client
- `LocationService.swift` - Core Location integration

**Utilities Layer:**
- `Constants.swift` - App-wide constants and configurations
- `Extensions.swift` - Helper extensions on standard types
- `GlassEffectModifiers.swift` - Custom SwiftUI modifiers for glass effects
- `Config.swift` - Sensitive configuration (API keys, not in git)

## 🔑 API Configuration

### Supabase Configuration

```swift
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey
        )
    }
}
```

### Weather API Configuration

```swift
import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = Config.weatherAPIKey
    private let baseURL = Config. weatherAPIBaseURL
    
    func fetchWeather(for city: String) async throws -> Weather {
        let endpoint = "\(baseURL)/weather? q=\(city)&appid=\(apiKey)&units=metric"
        // Implementation... 
    }
}
```

## 📸 Screenshots

> **Note:** Add screenshots here showcasing: 
> - Authentication screen with glass effects
> - Home screen with current weather
> - 5-day forecast cards
> - City search interface
> - Settings screen

```
[Auth Screen] [Home Screen] [Search] [Settings]
```

## 💻 Development Workflow

### 1. AI-First Development Cycle

```
1. Define feature requirements
2. Create detailed prompt for AI
3. Generate initial code with Claude/Cursor
4. Review and refine code
5. Test on device/simulator
6. Iterate based on feedback
```

### 2. Version Control

```bash
# Commit message format
git commit -m "feat: Add city search with Supabase sync"
git commit -m "fix: Handle weather API error states"
git commit -m "style: Implement glass effect on forecast cards"
```

### 3. Testing Checklist

- [ ] Authentication flow (sign up, login, logout)
- [ ] Weather data fetching and display
- [ ] City search and favorites sync
- [ ] Pull-to-refresh functionality
- [ ] Temperature unit toggle
- [ ] Error handling (network, API limits)
- [ ] Loading states and animations
- [ ] Liquid Glass effects render correctly
- [ ] No crashes on iOS 26 device/simulator

## 📊 Evaluation Criteria

| Criteria | Weight | Key Aspects |
|----------|--------|-------------|
| **AI Workflow** | 40% | Effective prompting, iteration flow, handling AI mistakes, demonstrating AI-human collaboration |
| **UI Polish** | 35% | Liquid Glass implementation, animations, visual detail, production-ready feel |
| **Code Quality** | 25% | Clean architecture, error handling, security, code readability |

### AI Workflow (40%)
- ✅ Effective and clear prompting strategies
- ✅ Good iteration and refinement flow
- ✅ Knowing when to guide vs. let AI lead
- ✅ Handling AI mistakes gracefully
- ✅ Screen recording demonstrating workflow

### UI Polish (35%)
- ✅ iOS 26 Liquid Glass (. glassEffect(), GlassEffectContainer)
- ✅ Smooth animations and transitions
- ✅ Visual attention to detail
- ✅ Feels like a production app, not a prototype

### Code Quality (25%)
- ✅ MVVM architecture with clean separation
- ✅ Proper error handling and loading states
- ✅ No crashes on device/simulator
- ✅ Secure credential management (no hardcoded keys)

## 🎁 Bonus Features

### Advanced AI Workflows (Stand Out!)
- [ ] **Supabase MCP integration** - Database/auth setup via Claude Code
- [ ] **GitHub MCP** - Automated commits and PR workflows
- [ ] **Filesystem MCP** - AI-driven project management
- [ ] **Subagents** - Multi-agent task breakdown
- [ ] **Automated tests** - AI-generated unit and UI tests

### Enhanced App Features
- [ ] **Real-time sync** - Supabase Realtime for instant favorite updates
- [ ] **iOS Widgets** - Home screen widget showing current weather
- [ ] **Haptic feedback** - Tactile responses on interactions
- [ ] **Dark mode** - Proper glass adaptations for dark theme
- [ ] **Accessibility** - VoiceOver support and Dynamic Type
- [ ] **Location services** - Auto-detect current location
- [ ] **Weather notifications** - Daily forecast push notifications
- [ ] **Offline mode** - Cached weather data when offline

## 📚 Resources

### Official Documentation
- [iOS 26 Liquid Glass Reference](https://developer.apple.com/documentation/swiftui/glass-effects)
- [Apple WWDC25:  Build a SwiftUI app with the new design](https://developer.apple.com/wwdc25/)
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Swift SDK](https://github.com/supabase-community/supabase-swift)

### APIs
- [OpenWeatherMap API](https://openweathermap.org/api)
- [WeatherAPI](https://www.weatherapi.com/)
- [Tomorrow.io API](https://www.tomorrow.io/)

### AI Tools
- [Claude Code](https://claude.ai/code) - AI pair programming
- [Cursor](https://cursor.sh/) - AI-powered code editor
- [Supabase MCP Server](https://github.com/supabase/mcp) - For bonus points

### Design Tools
- [Google Stitch](https://stitch.google.com/) - AI design generation
- [Figma Make](https://www.figma.com/make) - AI-assisted prototyping

## 🤝 Contributing

This is an interview assignment project. However, suggestions and feedback are welcome!

## 📝 License

This project is created for educational and interview purposes. 

---

## 📧 Contact

**Developer:** Jay Doshi  
**GitHub:** [@jayDoshi11](https://github.com/jayDoshi11)  
**Assignment Questions:** team@thebrewapps.com

---

## 🎯 Deliverables Checklist

- [x] Complete source code in GitHub repository
- [x] README.md with detailed setup instructions
- [x] CLAUDE.md AI context file
- [ ] Screen recording (15-30 min) demonstrating AI workflow
- [ ] Design file from Google Stitch or Figma Make
- [ ] Supabase project configured with RLS
- [ ] Weather API integration working
- [ ] All core features implemented
- [ ] iOS 26 Liquid Glass design system applied

---

**Built with ❤️ using AI-first development practices**

**Assignment Deadline:** 3 days from receipt  
**Submission:** Via provided link

Good luck!  🚀

# SkinGlowing App Structure

## Navigation Flow
1. **BackWellApp.swift** - Main app entry point
2. **AppRootView.swift** - Controls navigation between screens:
   - Login → Onboarding → Main (3 tabs)
3. **MainTabView.swift** - Three-tab navigation:
   - Tab 1: HomeView (Skin Analysis)
   - Tab 2: RoutinesView (Beauty Routines)
   - Tab 3: SettingsView (Settings)

## Core Views

### Authentication & Onboarding
- **LoginView.swift** - Korean video background with pink gradient button
- **OnboardingView.swift** - iOS Health style skin analysis setup

### Main Features
- **Views/HomeView.swift** - Skin scanning and analysis dashboard
- **Views/RoutinesView.swift** - Beauty routines (Glass Skin, Gua Sha, etc.)
- **Views/SkinScanView.swift** - Camera-based skin analysis
- **Views/ArchiveView.swift** - Scan history and progress tracking
- **Views/NewArchiveView.swift** - Redesigned archive with white/pink theme

### Supporting Views
- **SettingsView.swift** - App settings and account management
- **Views/RoutineMakerView.swift** - Create custom beauty routines
- **Views/ArisaChatView.swift** - AI beauty assistant

## Utilities
- **LoopingVideoPlayer.swift** - Video background player
- **Theme.swift** - Color scheme and styling
- **StoreManager.swift** - In-app purchases
- **SuperwallPurchaseController.swift** - Paywall management

## Files Removed (Streamlined)
- ✅ MainAppView.swift (replaced with MainTabView)
- ✅ ExerciseData.swift (not needed for beauty app)
- ✅ ExercisePlayerView.swift (not needed for beauty app)
- ✅ ContentView.swift (unused)

## Color Scheme
- Primary: Pink (#FF91A4)
- Secondary: Light Pink (#FFB6C1)
- Background: White with pink gradients
- Accent: Pink tones throughout

## App Flow
1. User opens app → LoginView
2. After login → OnboardingView (photo upload, skin analysis)
3. After onboarding → MainTabView with 3 tabs
4. Main features: Skin scanning, Beauty routines, Progress tracking
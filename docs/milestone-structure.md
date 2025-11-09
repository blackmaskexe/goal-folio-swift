Milestone 1: Core iOS/Swift (Static UI, Local State, Persistence)
You start with the bare essentials: an app entry point, a tab manager, your two main feature views, a model for your data, and a simple persistence service. We'll introduce ViewModels right away to manage the state for your Watchlist.

StockTracker/
│
├── 📱 App
│   ├── StockTrackerApp.swift   // @main entry point
│   └── MainTabView.swift       // (M1.1) Hosts the TabView
│
├── ✨ Features
│   ├── Watchlist
│   │   ├── Views
│   │   │   ├── WatchlistView.swift     // (M1.1) The main list screen
│   │   │   └── + AddTickerView.swift   // (M1.2) The form to add a symbol
│   │   └── + ViewModels
│   │       └── + WatchlistViewModel.swift // (M1.2) Manages the @State list of tickers
│   │
│   └── Portfolio
│       └── Views
│           └── PortfolioView.swift     // (M1.1) Static placeholder screen
│
├── 📦 Core
│   ├── Models
│   │   └── + Ticker.swift          // (M1.2) Your first model: struct Ticker
│   └── + Services
│       └── + Persistence
│           └── + PersistenceService.swift // (M1.3) Saves/loads [Ticker] using UserDefaults
│
└── ⚙️ Support
    ├── Assets.xcassets         // AppIcon, colors
    └── Info.plist
Key changes in this step:

You built the app's skeleton (MainTabView and the two feature views).

For M1.2, you added a Ticker model, an AddTickerView form, and a WatchlistViewModel to manage the array of tickers.

For M1.3, you created your first service, PersistenceService, which the WatchlistViewModel will use to save and load its ticker array.

Milestone 2: Networking (Async/Await)
Now you need to fetch live data. This is a classic "Service" task. You'll create a Networking service and update your WatchlistViewModel to use it. You'll also need a new model to decode the JSON response from your API.

StockTracker/
│
├── 📦 Core
│   ├── Models
│   │   ├── Ticker.swift
│   │   └── + PriceResponse.swift   // (M2.4) Codable struct for API's JSON
│   └── Services
│       ├── Persistence
│       │   └── PersistenceService.swift
│       └── + Networking            // (M2.4) New group for network logic
│           ├── + APIService.swift    // (M2.4) Protocol & class for URLSession
│           └── + APIError.swift    // (M2.4) Custom enum for network errors
...
Key changes in this step:

You added Core/Services/Networking to hold your APIService. This service will be responsible for all async/await URLSession calls.

You added Core/Models/PriceResponse.swift to easily decode the JSON.

No new feature folders: Instead, you will modify WatchlistViewModel.swift (from M1) to call APIService.fetchPrices(). This is a common pattern: your ViewModels coordinate services.

Milestone 3: Portfolio Modeling (Manual)
This is very similar to Milestone 1, but for the Portfolio feature. You're adding a new model (Position), new views for adding/showing positions, and a new ViewModel. You'll also start a Common folder for reusable code like formatters.

StockTracker/
│
├── ✨ Features
│   ├── Watchlist
│   │   ... (no changes)
│   └── Portfolio
│       ├── Views
│       │   ├── PortfolioView.swift   // (M1.1) This view gets updated
│       │   └── + AddPositionView.swift // (M3.6) Form to add a new position
│       └── + ViewModels
│           └── + PortfolioViewModel.swift // (M3.6) Manages positions, computes value
│
├── 📦 Core
│   ├── Models
│   │   ├── Ticker.swift
│   │   ├── PriceResponse.swift
│   │   └── + Position.swift        // (M3.6) struct Position { ticker, shares, cost }
│   ├── Services
│   │   ... (no changes here, but...)
│   └── + Common                  // (M3.6) New group for reusable helpers
│       └── + Utilities
│           └── + NumberFormatters.swift // (M3.6) For formatting currency
...
Key changes in this step:

The Portfolio feature gets its own PortfolioViewModel and AddPositionView, just as Watchlist did.

You added a Position model.

You created a Common/Utilities folder for your currency formatter. This keeps your Views clean.

Modification: You will update your existing PersistenceService.swift (from M1.3) to also handle saving and loading the [Position] array (M3.7).

Milestone 4: Analytics and Goals (Local-only)
You're adding a brand new feature: "Goals." This will be a new tab or a new screen. It gets its own folder under Features.

StockTracker/
│
├── ✨ Features
│   ├── Watchlist
│   │   ...
│   ├── Portfolio
│   │   ...
│   └── + Goals                   // (M4.8) Brand new feature
│       ├── + Views
│       │   ├── + GoalSummaryView.swift   // (M4.8) Shows progress
│       │   ├── + ContributionLogView.swift // (M4.9) List of contributions
│       │   └── + AddContributionView.swift // (M4.9) Form to add a contribution
│       └── + ViewModels
│           └── + GoalViewModel.swift     // (M4.8, M4.10) Manages goal, logs, projections
│
├── 📦 Core
│   ├── Models
│   │   ... (existing models)
│   │   └── + Contribution.swift    // (M4.9) struct Contribution { date, amount }
│   ├── Common
│   │   └── + Extensions            // (M4.9)
│   │       └── + Date+Formatting.swift
│   ...
Key changes in this step:

You added a complete Features/Goals folder, following the same View/ViewModel pattern.

You added the Contribution model.

Modification: You will update PersistenceService.swift (from M1.3) again to save the user's goal and their [Contribution] array.

Milestone 5: Better Data and UX (Charts)
You need a "detail" screen that shows when a user taps a ticker. This screen will have a chart. This is a new, reusable feature.

StockTracker/
│
├── ✨ Features
│   ... (Watchlist, Portfolio, Goals)
│   └── + TickerDetail            // (M5.11) New feature screen
│       ├── + Views
│       │   └── + TickerDetailView.swift
│       ├── + ViewModels
│       │   └── + TickerDetailViewModel.swift // Fetches historical data
│       └── + Components
│           └── + PriceHistoryChartView.swift // (M5.11) The reusable Swift Chart
...
Key changes in this step:

You added Features/TickerDetail. This screen will be navigated to from both the Watchlist and Portfolio views.

It has its own ViewModel to fetch its own data (historical prices).

Modification: You will update APIService.swift (from M2) to add a new function, fetchPriceHistory(for:).

Modification: You will update PortfolioViewModel.swift (from M3) to add the new computed metrics (P/L, etc.) (M5.12).

Milestone 6: Plaid Integration
This is a major new service. You're not adding UI features (yet), but you are adding the core logic to communicate with Plaid and (smartly) your own backend.

StockTracker/
│
├── 📦 Core
│   ├── Services
│   │   ├── Persistence
│   │   ├── Networking
│   │   └── + Plaid                 // (M6.13) All Plaid logic lives here
│   │       ├── + PlaidService.swift      // (M6.13) Handles the Link SDK flow
│   │       └── + PlaidTokenExchanger.swift // (M6.14) Talks to *your* backend
...
Key changes in this step:

This is purely a Core/Services addition.

PlaidService.swift will contain the code to launch the Plaid Link flow.

PlaidTokenExchanger.swift is the client-side code that securely sends the public token to your server and gets an access token back. This is not your backend server; it's the part of your app that talks to it.

Modification: Your GoalViewModel (from M4) or ContributionLogView will be updated to use the PlaidService to auto-populate contributions (M6.15).

Milestone 7: Polish, Settings, and Testing
You're finishing the app. This means adding a Settings screen, robust testing, and other app-level features.

StockTracker/
│
├── 📱 App
│   ...
│
├── ✨ Features
│   ... (all your existing features)
│   └── + Settings                // (M7.19) New feature for app settings
│       ├── + Views
│       │   └── + SettingsView.swift
│       └── + ViewModels
│           └── + SettingsViewModel.swift // Manages @AppStorage properties
│
├── 📦 Core
│   ... (Common, Models)
│   ├── Services
│   │   ... (Networking, Persistence, Plaid)
│   │   └── + Notifications         // (M7.18) For price alerts
│   │       └── + NotificationManager.swift
│
├── ⚙️ Support
│   ├── Assets.xcassets
│   ├── Info.plist
│   └── + Preview Content         // (M7.20)
│       └── + MockData.swift        // Provides mock models for SwiftUI Previews
│
└── 🧪 StockTrackerTests         // (M7.20) A NEW Xcode Target
    ├── + UnitTests
    │   ├── + ModelTests
    │   │   └── + PositionTests.swift
    │   ├── + ViewModelTests
    │   │   └── + PortfolioViewModelTests.swift
    │   └── + ServiceTests
    │       └── + APIServiceTests.swift
    └── + Mocks
        └── + MockAPIService.swift    // A fake APIService for testing
Key changes in this step:

You added Features/Settings to manage user preferences.

You added Support/Preview Content to make your SwiftUI Previews fast and reliable.

You added a completely new Xcode Target called StockTrackerTests. This is where all your unit tests live. This is the foundation of M7.20 (Testing and Reliability).

You might also add another new Target, StockTrackerWidgets (M7.18), for Home Screen widgets.

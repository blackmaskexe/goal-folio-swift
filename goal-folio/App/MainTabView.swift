//
//  MainTabView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Hosts the TabView

import SwiftUI

struct MainTabView: View {
    @StateObject private var stockStore = StockStore()
    @StateObject private var loadingManager = LoadingManager()
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Watchlist", systemImage: "star") {
                    NavigationStack {
                        WatchlistView()
                    }
                    
                }
                
                Tab("Portfolio", systemImage: "person") {
                    NavigationStack {
                        PortfolioView()
                    }
                    
                }
            }
            .environmentObject(stockStore)
            .environmentObject(loadingManager)
            
            // Loading Overlay Logic
            if loadingManager.isLoading {
                ZStack {
                    // Dimmed background only behind the loader
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.accentColor) // App accent color
                        // Optional: Add text or spacing if desired
                    }
                    .padding(32)
                    .background(
                        Color.black.opacity(0.15) // Or use .thinMaterial for a glassy look
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    // Remove ignoresSafeArea so only the ProgressView has overlay
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear) // No global dimming
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: loadingManager.isLoading)
            }
            
        }
    }
}

#Preview {
    MainTabView()
}

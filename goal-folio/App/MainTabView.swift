//
//  MainTabView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Hosts the TabView

import SwiftUI

struct MainTabView: View {
    @StateObject private var tickerStore = TickerStore()
    var body: some View {
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
            .environmentObject(tickerStore)

        }
}

#Preview {
    MainTabView()
}

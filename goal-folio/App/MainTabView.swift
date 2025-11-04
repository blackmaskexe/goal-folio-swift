//
//  MainTabView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Hosts the TabView

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
            
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainTabView()
}

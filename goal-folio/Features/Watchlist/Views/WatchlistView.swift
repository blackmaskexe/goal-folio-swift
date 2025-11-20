//
//  WatchlistView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Static placeholder screen

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var stockStore: StockStore
    @EnvironmentObject var loadingManager: LoadingManager

    @State var searchText: String = ""
    @State var displayedStocks: [Stock] = []
    @FocusState private var isSearchFocused: Bool
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        FavoriteStockView(stocks: displayedStocks, isSearchFocused: false)
            .navigationTitle("Stock Watchlist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchStocksView()
                            .environmentObject(loadingManager)
                            .environmentObject(stockStore)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                // Show saved/favorite stocks on the main screen
                displayedStocks = stockStore.savedStocks
            }
    }
}

struct StockCard: View {
    let symbol: String
    let name: String

    var body: some View {
        NavigationLink {
            StockView(symbol: symbol, name: name)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(symbol)
                        .font(.headline)
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .padding()
            }
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}

struct FavoriteStockView: View {
    var stocks: [Stock]
    var isSearchFocused: Bool

    var body: some View {
        ScrollView {
            Text("Favorite Stocks")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 8) {
                ForEach(stocks, id: \.self) { stock in
                    StockCard(symbol: stock.symbol, name: stock.name)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}




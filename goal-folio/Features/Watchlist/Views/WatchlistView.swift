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
    
    private var isShowingSearchbar: Bool {
        return isSearchFocused || !searchText.isEmpty
    }
        
    private func setRemoteSearchStocks () async -> Void {
        do {
            loadingManager.show()
            let stocks = try await StockFirebaseService.shared.searchStocks(query: searchText, limit: 10)
            displayedStocks = stocks
            loadingManager.hide()
        } catch {
            print("Error: \(error)")
            displayedStocks = []
            loadingManager.hide()
        }
    }

    var body: some View {
        FavoriteStockView(stocks: displayedStocks, isSearchFocused: isSearchFocused)
            .searchable(text: $searchText, prompt: "Search a Stock")
            .searchFocused($isSearchFocused)
            .navigationTitle("Stock Watchlist")
            .onAppear {
                isSearchFocused = false
                searchText = ""
                displayedStocks = stockStore.savedStocks
            }
            .onChange(of: isSearchFocused) {
                print(isSearchFocused, "Im a pimp named slickback")
                // flow to show the appropriate stocks:
                // 1. search isn't focused -> show saved stocks
                // 2. search is focused:
                    // a. No text -> Show static Stocks
                    // b. There is text?
                        // the user stops typing for ~200-300 ms, run API Call
                        // show a loading bar type beat while this is happening
                        // once fetched, show them
                
                if isSearchFocused {
                    if searchText == "" {
                        displayedStocks = StaticStockData.all
                    } else {
                        // handled by .onChange(of: searchText)
                    }
                } else {
                    displayedStocks = stockStore.savedStocks
                    searchText = ""
                }
            }
            .onChange(of: searchText) {
                // Debounce logic: Each time searchText changes, cancel previous task and start a new one
                searchTask?.cancel()
                if isSearchFocused {
                    if searchText.isEmpty {
                        displayedStocks = StaticStockData.all
                    } else {
                        searchTask = Task {
                            // Wait 250ms, cancel if searchText changes again in that time
                            try? await Task.sleep(nanoseconds: 250_000_000)
                            // Only run if task was not cancelled
                            await setRemoteSearchStocks()
                        }
                    }
                }
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
            if !isSearchFocused {
                Text("Favorite Stocks")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

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

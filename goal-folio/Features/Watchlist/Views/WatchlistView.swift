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

// MARK: - Dedicated Search Screen

struct SearchStocksView: View {
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var stockStore: StockStore

    @State private var query: String = ""
    @State private var results: [Stock] = []
    @State private var searchTask: Task<Void, Never>? = nil
    @FocusState private var isFieldFocused: Bool

    private var showSuggestions: Bool {
        isFieldFocused && query.isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            // Custom Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search a Stock", text: $query)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .focused($isFieldFocused)
                    .onChange(of: query) {
                        debounceSearch()
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                        results = StaticStockData.all
                        isFieldFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal)

            // Content
            Group {
                if showSuggestions {
                    SuggestionsList(stocks: StaticStockData.all)
                } else {
                    ResultsList(stocks: results)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Start with suggestions visible and focus the field
            results = StaticStockData.all
            isFieldFocused = true
        }
        .onDisappear {
            searchTask?.cancel()
            searchTask = nil
        }
    }

    // MARK: - Debounce and search

    private func debounceSearch() {
        searchTask?.cancel()
        if query.isEmpty {
            // When cleared, show suggestions
            results = StaticStockData.all
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            await performSearch()
        }
    }

    @MainActor
    private func performSearch() async {
        do {
            loadingManager.show()
            let stocks = try await StockFirebaseService.shared.searchStocks(query: query, limit: 10)
            results = stocks
            loadingManager.hide()
        } catch {
            print("Search error: \(error)")
            results = []
            loadingManager.hide()
        }
    }
}

// MARK: - Subviews for Search Screen

private struct SuggestionsList: View {
    let stocks: [Stock]

    var body: some View {
        List {
            Section("Suggestions") {
                ForEach(stocks, id: \.self) { stock in
                    NavigationLink {
                        StockView(symbol: stock.symbol, name: stock.name)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stock.symbol).font(.headline)
                            Text(stock.name).font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct ResultsList: View {
    let stocks: [Stock]

    var body: some View {
        List {
            if stocks.isEmpty {
                Text("No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(stocks, id: \.self) { stock in
                    NavigationLink {
                        StockView(symbol: stock.symbol, name: stock.name)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stock.symbol).font(.headline)
                            Text(stock.name).font(.subheadline).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

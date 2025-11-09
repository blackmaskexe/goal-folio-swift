//
//  WatchlistView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Static placeholder screen


// In-order implementation:
// 1. dummy search bar on top
// 2. a bunch of cards for different stocks (static at this point)


import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var tickerStore: TickerStore
    @State var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    // TODO: make it so that when there is something inside of searchText,
    // 1. fetch a list of static stocks (expansive list) that looks through, even if not favorited
    // 2. then when comfortable, fetch the stocks from an api or something like that
    
    private var displayedTickers: [Ticker] {
        // 1. If the search is focused, show an expansive list of stocks (static at the moment)
        if isSearchFocused {
            // Depending on if the user has searched anything
            // in the searchbar or not:
            if searchText == "" {
                return StaticTickersData.all
            }
            return StaticTickersData.all.filter {
                $0.symbol.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
             else {
                return tickerStore.savedTickers
            }
    }
   
    
    var body: some View {
        FavoriteTickerView(tickers: displayedTickers, isSearchFocused: isSearchFocused)
            .searchable(text: $searchText, prompt: "Search a Stock")
            .searchFocused($isSearchFocused)
            .navigationTitle("Stock Watchlist")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        print("Icon tapped")
//                    } label: {
//                        Image(systemName: "plus")
//                            .foregroundStyle(Color.accentColor)
//                    }
//                }
//            }
    }
}

struct TickerCard: View {
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

struct FavoriteTickerView: View {
    var tickers: [Ticker]
    var isSearchFocused: Bool
    
    var body: some View {
        ScrollView {
            
            if !isSearchFocused {
                Text("Favorite Stocks")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(spacing: 8) {
                ForEach(tickers, id: \.self) { ticker in
                    TickerCard(symbol: ticker.symbol, name: ticker.name)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

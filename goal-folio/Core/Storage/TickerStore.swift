//
//  TickerStore.swift.swift
//  goal-folio
//
//  Created by Pratham S on 11/8/25.
//

import SwiftUI
import Combine

class TickerStore: ObservableObject {
    @AppStorage("savedTickers") private var tickerData: Data = Data()
    @Published var savedTickers: [Ticker] = []
    
    init() {
        savedTickers = (try? JSONDecoder().decode([Ticker].self, from: tickerData)) ?? []
        
        // If there are no saved stocks, we'll save these 4 default ones in the user's favorites
        if savedTickers.isEmpty {
            savedTickers = [
                Ticker(symbol: "AAPL", name: "Apple Inc."),
                Ticker(symbol: "GOOGL", name: "Alphabet Inc."),
                Ticker(symbol: "AMZN", name: "Amazon.com, Inc."),
                Ticker(symbol: "VOO", name: "Vanguard S&P 500 ETF")
            ]
            save()
        }
    }
    
    private func save() {
        tickerData = (try? JSONEncoder().encode(savedTickers)) ?? Data()
    }
    
    func saveTicker(symbol: String, name: String) {
        savedTickers.append(Ticker(symbol: symbol, name: name))
        save()
    }
    
    func removeTicker(symbol: String) {
        savedTickers.removeAll {$0.symbol.lowercased() == symbol.lowercased()}
    }
}

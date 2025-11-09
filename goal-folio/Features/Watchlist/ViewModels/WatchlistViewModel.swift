//
//  WatchlistViewModel.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//

import Combine
import Foundation

class WatchlistViewModel: ObservableObject {
    @Published var tickers: [Ticker]
    
    init() {
        // hardcoding tickers:
        self.tickers = [
            Ticker(symbol: "AAPL", name: "Apple Inc."),
            Ticker(symbol: "MSFT", name: "Microsoft Corp."),
            Ticker(symbol: "GOOG", name: "Alphabet Inc."),
            Ticker(symbol: "TSLA", name: "Tesla, Inc.")
        ]
    }
    
    func addDummyTicker () {
        self.tickers.append(Ticker(symbol: "PPL", name: "Paypal"))
    }
}

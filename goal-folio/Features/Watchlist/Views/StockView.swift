//
//  StockView.swift
//  goal-folio
//
//  Created by Pratham S on 11/6/25.
//

import SwiftUI

struct StockView: View {
    let symbol: String
    let name: String
    private let alphavantageService = AlphaVantageService()
    @EnvironmentObject var tickerStore: TickerStore
    @State private var stockCandles: [StockCandle] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                
                if tickerStore.isTickerSaved(symbol: symbol) {
                    Button("Remove stock from favorites") {
                        tickerStore.removeTicker(symbol: symbol)
                    }
                } else {
                    Button("Add stock to favorites") {
                        tickerStore.saveTicker(symbol: symbol, name: name)
                    }
                }
                
            }
            
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                StocksChart(stockCandles: stockCandles)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .navigationTitle(name)
            .onAppear {
                Task {
                    do {
                        stockCandles = try await alphavantageService.getRecentOpenDayCandles(symbol: symbol)
                    } catch {
                        print("Error: ", error.localizedDescription)
                    }
                    
                }
                
            }
            
        }
    }
}

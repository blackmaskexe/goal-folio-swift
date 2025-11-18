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
    @EnvironmentObject var stockStore: StockStore
    @EnvironmentObject var loadingManager: LoadingManager
    
    @State private var stockCandles: [StockCandle] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                
                if stockStore.isStockSaved(symbol: symbol) {
                    Button("Remove stock from favorites") {
                        stockStore.removeStock(symbol: symbol)
                    }
                } else {
                    Button("Add stock to favorites") {
                        stockStore.saveStock(symbol: symbol, name: name)
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
                        loadingManager.show()
                        stockCandles = try await alphavantageService.getRecentOpenDayCandles(symbol: symbol)
                        loadingManager.hide()
                    } catch {
                        print("Error: ", error.localizedDescription)
                        loadingManager.hide()
                    }
                    
                }
                
            }
            
        }
    }
}

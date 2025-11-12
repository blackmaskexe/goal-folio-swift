//
//  StocksChart.swift
//  goal-folio
//
//  Created by Pratham S on 11/9/25.
//

import SwiftUI
import Charts

struct StocksChart: View {
    let stockCandles: [StockCandle]
    
    var body: some View {
        let prices = stockCandles.map {$0.close}
        let graphMinPrice = (prices.min() ?? 0) * 0.995; // 0.995 for padding
        let graphMaxPrice = (prices.max() ?? 0) * 1.005; // 1.005 for padding

        Chart(stockCandles) {
            LineMark(
                x: .value("Time", $0.time),
                y: .value("Price", $0.close)
            )
        }
        .chartYScale(domain: graphMinPrice...graphMaxPrice)
    }
}


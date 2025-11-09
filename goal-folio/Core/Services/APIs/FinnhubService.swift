//
//  FinnhubService.swift
//  goal-folio
//
//  Created by Pratham S on 11/7/25.
//

import Alamofire

struct StockQuote: Decodable, @unchecked Sendable {
    let c: Double // current price
    let h: Double  // High price of the day
    let l: Double  // Low price of the day
    let o: Double  // Open price of the day
    let pc: Double // Previous close price
}


class FinnhubService {
    private let baseURL = "https://finnhub.io/api/v1"
    private let apiKey = "d475s7hr01qh8nnba2agd475s7hr01qh8nnba2b0"
    
    func fetchStockQuote(symbol: String) async throws -> StockQuote {
            let endpoint = "\(baseURL)/quote"
            let parameters: [String: String] = [
                "symbol": symbol,
                "token": apiKey
            ]
            
            let response = await AF.request(endpoint,
                                            parameters: parameters,
                                            interceptor: .retryPolicy)
                .validate()
                .serializingDecodable(StockQuote.self)
                .response
            
//            debugPrint(response) // optional debugging log
            
            return try response.result.get() // return parsed model
        }
    
}


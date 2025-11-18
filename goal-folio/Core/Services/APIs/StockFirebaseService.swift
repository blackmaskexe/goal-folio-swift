//
//  StockFirebaseService.swift
//  goal-folio
//
//  Created by Pratham S on 11/14/25.
//


import Foundation
import FirebaseFunctions

/// Service for fetching stock data through Firebase Cloud Functions
/// Replaces direct Alpha Vantage API calls with cached, rate-limited backend calls
class StockFirebaseService {
    
    // MARK: - Properties
    
    /// Firebase Functions instance
    private let functions = Functions.functions()
    
    /// Shared singleton instance
    static let shared = StockFirebaseService()
    
    // MARK: - Initialization
    
    private init() {
        // Optional: Configure for specific region if needed
        // functions = Functions.functions(region: "us-central1")
    }
    
    // MARK: - Models
    
    /// Stock search result

    
    /// Stock candle (OHLCV) data point
    struct StockCandle: Codable {
        let time: String // ISO 8601 timestamp
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let volume: Int
        
        /// Converts ISO timestamp to Date
        var date: Date? {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: time)
        }
    }
    
    /// Search response from Firebase
    struct SearchResponse: Codable {
        let success: Bool
        let query: String
        let count: Int
        let fromCache: Bool
        let results: [Stock]
        let apiError: String?
    }
    
    /// Stock details response
    struct StockDetailsResponse: Codable {
        let success: Bool
        let result: StockDetails?
        let error: String?
    }
    
    struct StockDetails: Codable {
        let symbol: String
        let name: String
        let type: String
        let region: String
        let currency: String
        let lastUpdated: String
    }
    
    /// Intraday prices response
    struct IntradayPricesResponse: Codable {
        let success: Bool
        let symbol: String
        let interval: String
        let outputSize: String
        let adjusted: Bool
        let extendedHours: Bool
        let month: String?
        let count: Int
        let prices: [StockCandle]
        let error: String?
    }
    
    /// Recent open day response
    struct RecentOpenDayResponse: Codable {
        let success: Bool
        let symbol: String
        let interval: String
        let tradingDay: String?
        let count: Int
        let candles: [StockCandle]
        let error: String?
    }
    
    // MARK: - Errors
    
    enum FirebaseServiceError: LocalizedError {
        case invalidResponse
        case serverError(String)
        case noData
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from server"
            case .serverError(let message):
                return "Server error: \(message)"
            case .noData:
                return "No data received"
            }
        }
    }
    
    // MARK: - Search Functions
    
    /// Search for stocks by symbol or name
    /// - Parameters:
    ///   - query: Search query (e.g., "AAPL" or "Apple")
    ///   - limit: Maximum number of results (default: 10, max: 50)
    /// - Returns: Array of matching stocks
    func searchStocks(query: String, limit: Int = 10) async throws -> [Stock] {
        let baseURL = "https://us-central1-goal-folio.cloudfunctions.net/searchStocks"
        
        guard let url = URL(string: baseURL) else {
            throw FirebaseServiceError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "q": query,
            "limit": min(limit, 50)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        if !response.success {
            if let apiError = response.apiError {
                throw FirebaseServiceError.serverError(apiError)
            }
            throw FirebaseServiceError.serverError("Unknown error")
        }
        
        return response.results
    }
    
    /// Get detailed information about a specific stock
    /// - Parameter symbol: Stock symbol (e.g., "AAPL")
    /// - Returns: Stock details
    func getStock(symbol: String) async throws -> StockDetails {
        let data: [String: Any] = [
            "symbol": symbol.uppercased()
        ]
        
        let result = try await functions.httpsCallable("getStock").call(data)
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: result.data),
              let response = try? JSONDecoder().decode(StockDetailsResponse.self, from: jsonData) else {
            throw FirebaseServiceError.invalidResponse
        }
        
        if !response.success {
            throw FirebaseServiceError.serverError(response.error ?? "Unknown error")
        }
        
        guard let stockDetails = response.result else {
            throw FirebaseServiceError.noData
        }
        
        return stockDetails
    }
    
    // MARK: - Price Functions
    
    /// Fetch intraday prices for a stock
    /// - Parameters:
    ///   - symbol: Stock symbol (e.g., "AAPL")
    ///   - interval: Time interval (default: "15min")
    ///   - outputSize: "compact" (latest 100 data points) or "full" (trailing 30 days) (default: "compact")
    ///   - adjusted: Split/dividend-adjusted data (default: true)
    ///   - extendedHours: Include pre/post-market hours (default: false)
    ///   - month: Specific month in YYYY-MM format (optional, e.g., "2024-11")
    /// - Returns: Array of stock candles sorted by time
    func fetchIntradayPrices(
        symbol: String,
        interval: String = "15min",
        outputSize: String = "compact",
        adjusted: Bool = true,
        extendedHours: Bool = false,
        month: String? = nil
    ) async throws -> [StockCandle] {
        // Use direct HTTP call since this endpoint uses query parameters
        let baseURL = "https://getintradayprices-flsqckpzha-uc.a.run.app"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "symbol", value: symbol.uppercased()),
            URLQueryItem(name: "interval", value: interval),
            URLQueryItem(name: "outputSize", value: outputSize),
            URLQueryItem(name: "adjusted", value: String(adjusted)),
            URLQueryItem(name: "extendedHours", value: String(extendedHours))
        ]
        
        if let month = month {
            components.queryItems?.append(URLQueryItem(name: "month", value: month))
        }
        
        guard let url = components.url else {
            throw FirebaseServiceError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(IntradayPricesResponse.self, from: data)
        
        if !response.success {
            throw FirebaseServiceError.serverError(response.error ?? "Unknown error")
        }
        
        return response.prices
    }
    
    /// Get candles for the most recent open trading day
    /// - Parameters:
    ///   - symbol: Stock symbol (e.g., "AAPL")
    ///   - interval: Time interval (default: "15min")
    /// - Returns: Array of candles for the most recent trading day
    func getRecentOpenDayCandles(
        symbol: String,
        interval: String = "15min"
    ) async throws -> [StockCandle] {
        // Use direct HTTP call since this endpoint uses query parameters
        let baseURL = "https://getrecentopenday-flsqckpzha-uc.a.run.app"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "symbol", value: symbol.uppercased()),
            URLQueryItem(name: "interval", value: interval)
        ]
        
        guard let url = components.url else {
            throw FirebaseServiceError.invalidResponse
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RecentOpenDayResponse.self, from: data)
        
        if !response.success {
            throw FirebaseServiceError.serverError(response.error ?? "Unknown error")
        }
        
        return response.candles
    }
    
    // MARK: - Convenience Functions
    
    /// Get available time intervals for intraday prices
    static let availableIntervals = ["1min", "5min", "15min", "30min", "60min"]
    
    /// Validate time interval
    static func isValidInterval(_ interval: String) -> Bool {
        return availableIntervals.contains(interval)
    }
    
    /// Get the latest price from candles
    /// - Parameter candles: Array of stock candles
    /// - Returns: The most recent close price, or nil if empty
    static func getLatestPrice(from candles: [StockCandle]) -> Double? {
        return candles.last?.close
    }
    
    /// Calculate price change from candles
    /// - Parameter candles: Array of stock candles (must be sorted by time)
    /// - Returns: Tuple of (priceChange, percentChange) or nil if insufficient data
    static func getPriceChange(from candles: [StockCandle]) -> (change: Double, percentChange: Double)? {
        guard let first = candles.first,
              let last = candles.last,
              first.close > 0 else {
            return nil
        }
        
        let change = last.close - first.close
        let percentChange = (change / first.close) * 100.0
        
        return (change, percentChange)
    }
}

// MARK: - Usage Examples

/*
 
 // EXAMPLE 1: Search for stocks
 Task {
     do {
         let stocks = try await StockFirebaseService.shared.searchStocks(query: "Apple", limit: 10)
         for stock in stocks {
             print("\(stock.symbol): \(stock.name)")
         }
     } catch {
         print("Search failed: \(error.localizedDescription)")
     }
 }
 
 // EXAMPLE 2: Get stock details
 Task {
     do {
         let details = try await StockFirebaseService.shared.getStock(symbol: "AAPL")
         print("Stock: \(details.name)")
         print("Type: \(details.type)")
         print("Currency: \(details.currency)")
     } catch {
         print("Failed to get stock: \(error.localizedDescription)")
     }
 }
 
 // EXAMPLE 3: Fetch intraday prices
 Task {
     do {
         let candles = try await StockFirebaseService.shared.fetchIntradayPrices(
             symbol: "AAPL",
             interval: "15min",
             outputSize: "compact"
         )
         
         if let latestPrice = StockFirebaseService.getLatestPrice(from: candles) {
             print("Latest price: $\(latestPrice)")
         }
         
         if let change = StockFirebaseService.getPriceChange(from: candles) {
             print("Change: $\(change.change) (\(change.percentChange)%)")
         }
     } catch {
         print("Failed to fetch prices: \(error.localizedDescription)")
     }
 }
 
 // EXAMPLE 4: Get recent open day candles
 Task {
     do {
         let candles = try await StockFirebaseService.shared.getRecentOpenDayCandles(
             symbol: "AAPL",
             interval: "15min"
         )
         
         print("Trading day has \(candles.count) candles")
         for candle in candles {
             print("\(candle.time): Close $\(candle.close)")
         }
     } catch {
         print("Failed to get candles: \(error.localizedDescription)")
     }
 }
 
 // EXAMPLE 5: Fetch historical month data
 Task {
     do {
         let candles = try await StockFirebaseService.shared.fetchIntradayPrices(
             symbol: "AAPL",
             interval: "60min",
             outputSize: "full",
             month: "2024-11"
         )
         print("November 2024 has \(candles.count) hourly candles")
     } catch {
         print("Failed to fetch historical data: \(error.localizedDescription)")
     }
 }
 
 */

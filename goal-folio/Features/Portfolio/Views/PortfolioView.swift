//
//  PortfolioView.swift
//  goal-folio
//
//  Created by Pratham S on 11/4/25.
//
// (M1.1) Static placeholder screen

import SwiftUI

struct PortfolioView: View {
    @State private var selectedRange: TimeRange = .oneD
    @State private var data: [Double] = TimeRange.oneD.sampleData
    @State private var currentValue: Double = 12_345.67
    @State private var changeValue: Double = 123.45
    @State private var changePercent: Double = 0.98

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Chart + Range Picker Card
                    VStack(alignment: .leading, spacing: 12) {
                        // Time range selector
                        RangePicker(selected: $selectedRange) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                data = selectedRange.sampleData
                                // Update dummy summary numbers based on range to look dynamic
                                let base = 12_000.0
                                currentValue = base + (data.last ?? 0)
                                changeValue = (data.last ?? 0) - (data.first ?? 0)
                                let first = max(1, data.first ?? 1)
                                changePercent = (changeValue / first) * 100
                            }
                        }

                        // Lightweight "chart"
                        LineChart(values: data)
                            .frame(height: 180)
                            .animation(.easeInOut, value: data)

                        // Portfolio value
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Portfolio Value")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(currentValue.formatted(.currency(code: "USD")))
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                ChangePill(change: changeValue, percent: changePercent)
                            }
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Dummy sections
                    VStack(spacing: 16) {
                        HoldingsSection()
                        TopMoversSection()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Portfolio")
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            data = selectedRange.sampleData
        }
    }
}

// MARK: - Time Range

private enum TimeRange: String, CaseIterable, Identifiable {
    case oneD = "1D"
    case fiveD = "5D"
    case oneW = "1W"
    case oneM = "1M"
    case ytd = "YTD"
    case oneY = "1Y"

    var id: String { rawValue }

    // Dummy sample data per range; simple variations for visual interest
    var sampleData: [Double] {
        switch self {
        case .oneD:
            return Self.makeSeries(points: 24, volatility: 20, trend: 5)
        case .fiveD:
            return Self.makeSeries(points: 5 * 24, volatility: 30, trend: 3)
        case .oneW:
            return Self.makeSeries(points: 7 * 24, volatility: 35, trend: 2)
        case .oneM:
            return Self.makeSeries(points: 30, volatility: 40, trend: 1.5)
        case .ytd:
            return Self.makeSeries(points: 10, volatility: 60, trend: 2.0)
        case .oneY:
            return Self.makeSeries(points: 12, volatility: 80, trend: 2.5)
        }
    }

    private static func makeSeries(points: Int, volatility: Double, trend: Double) -> [Double] {
        var values: [Double] = []
        var current = 12_000.0
        for i in 0..<max(points, 2) {
            // deterministic pseudo randomness for previews without importing GameplayKit
            let seed = Double((i * 9301 + 49297) % 233280) / 233280.0
            let noise = (seed - 0.5) * volatility
            current += noise + trend
            values.append(current)
        }
        // Normalize around zero for simple line drawing relative to min
        if let minVal = values.min() {
            return values.map { $0 - minVal }
        }
        return values
    }
}

// MARK: - Range Picker

private struct RangePicker: View {
    @Binding var selected: TimeRange
    var onChange: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases) { range in
                Button {
                    guard selected != range else { return }
                    selected = range
                    onChange()
                } label: {
                    Text(range.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(selected == range ? Color.accentColor.opacity(0.15) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                // FIX: ShapeStyle has no member 'accent' -> use .tint or explicit Color
//                .foregroundStyle(selected == range ? .tint : .secondary)
            }
            Spacer()
        }
    }
}
// MARK: - Change Pill

private struct ChangePill: View {
    let change: Double
    let percent: Double

    var isUp: Bool { change >= 0 }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                .imageScale(.small)
            Text("\(change, format: .currency(code: "USD"))) (\(percent, specifier: "%.2f")%)")
        }
        .font(.footnote.weight(.semibold))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background((isUp ? Color.green : Color.red).opacity(0.15), in: Capsule())
        .foregroundStyle(isUp ? Color.green : Color.red)
    }
}

// MARK: - Dummy Sections

private struct HoldingsSection: View {
    struct Holding: Identifiable {
        let id = UUID()
        let symbol: String
        let name: String
        let shares: Double
        let value: Double
        let changePercent: Double
    }

    private let holdings: [Holding] = [
        .init(symbol: "AAPL", name: "Apple", shares: 12.5, value: 2_450, changePercent: 0.8),
        .init(symbol: "MSFT", name: "Microsoft", shares: 8.0, value: 2_180, changePercent: -0.4),
        .init(symbol: "VOO", name: "S&P 500 ETF", shares: 15.0, value: 6_120, changePercent: 0.2),
        .init(symbol: "TSLA", name: "Tesla", shares: 3.0, value: 690, changePercent: 2.3),
    ]

    var body: some View {
        SectionCard(title: "Holdings") {
            ForEach(holdings) { h in
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(h.symbol).font(.headline)
                            Text(h.name).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Text("\(h.shares, specifier: "%.2f") shares")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(h.value.formatted(.currency(code: "USD")))
                            .font(.headline)
                        Text("\(h.changePercent >= 0 ? "+" : "")\(h.changePercent, specifier: "%.2f")%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(h.changePercent >= 0 ? .green : .red)
                    }
                }
                .padding(.vertical, 8)
                Divider().opacity(0.15)
            }
        }
    }
}

private struct TopMoversSection: View {
    struct Mover: Identifiable {
        let id = UUID()
        let symbol: String
        let changePercent: Double
    }

    private let movers: [Mover] = [
        .init(symbol: "TSLA", changePercent: 3.4),
        .init(symbol: "NVDA", changePercent: 2.9),
        .init(symbol: "AMZN", changePercent: -1.8),
        .init(symbol: "AAPL", changePercent: 1.2),
    ]

    var body: some View {
        SectionCard(title: "Top Movers") {
            HStack(spacing: 12) {
                ForEach(movers) { m in
                    VStack(spacing: 6) {
                        Text(m.symbol)
                            .font(.subheadline.weight(.semibold))
                        Text("\(m.changePercent >= 0 ? "+" : "")\(m.changePercent, specifier: "%.2f")%")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(m.changePercent >= 0 ? .green : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}


// MARK: - Shared Section Card

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct CircleArc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return p
    }
}

#Preview {
    MainTabView()
}

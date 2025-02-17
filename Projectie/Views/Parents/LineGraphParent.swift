//
//  LineGraphParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct LineGraphParent: View {
    
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var controlManager: ControlManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    
    
    var body: some View {
        
        let allBalances = chartManager.chartDataPointsLine.map { $0.balance }
        
        let minBalance = allBalances.min() ?? 0
        let maxBalance = allBalances.max() ?? 0
        let chartMin = minBalance - (minBalance / 90)
        let chartMax = maxBalance + (maxBalance / 90)
        
        let today = Date()
        let startDate = timeManager.startDate
        let endDate = timeManager.endDate
        let showTodayLine = (today >= startDate && today <= endDate)
        
        return Chart {
            if !chartManager.isInteracting && showTodayLine {
                RuleMark(x: .value("Today", today))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
            
            if chartManager.isInteracting, let selectedDate = chartManager.selectedDate, let selectedBalance = chartManager.selectedBalance {
                // White vertical line
                RuleMark(x: .value("Selected X", selectedDate))
                    .foregroundStyle(Color.whiteInDarkBlackInLight)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                
                // White circle at the intersection
                PointMark(
                    x: .value("Selected X", selectedDate),
                    y: .value("Selected Y", selectedBalance)
                )
                .symbol(.circle)
                .symbolSize(40)
                .foregroundStyle(Color.whiteInDarkBlackInLight)
            }
            
            ForEach(chartManager.chartDataPointsLine, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(Color(themeManager.accentColor))
                .interpolationMethod(squareLines ? .stepEnd : .linear)
                
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    yStart: .value("Baseline", chartMin),
                    yEnd: .value("Balance", dataPoint.balance)
                )
                .interpolationMethod(squareLines ? .stepEnd : .linear)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(themeManager.accentColor).opacity(0.5),
                            Color(themeManager.accentColor).opacity(0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYAxis {
            AxisMarks(
                position: .leading,
                values: .automatic(desiredCount: 4)
            )
        }
        .chartYScale(domain: chartMin...chartMax)
        .frame(height: 180)
        .padding()
        .chartOverlay(content: { proxy in
            GeometryReader { geoProxy in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                
                                if (controlManager.selectedBottomView == .transactions) {
                                    chartManager.isInteracting = true
                                }
                                
                                let origin = geoProxy[proxy.plotFrame!].origin
                                let locationXOnChart = value.location.x - origin.x
                                
                                let screenWidth = geoProxy.size.width
                                let distanceToLeft = value.location.x
                                
                                let scrubOffset = distanceToLeft - (screenWidth / 2)
                                chartManager.setScrubbingHorizontalOffset(scrubOffset)
                                
                                if let date: Date = proxy.value(atX: locationXOnChart) {
                                    // Find the closest data point in filteredChartData
                                    if let closest = chartManager.chartDataPointsLine.min(by: {
                                        abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                    }) {
                                        chartManager.updateSelectedValues(closest.date, closest.balance)
                                    }
                                }
                            }
                            .onEnded { _ in
                                chartManager.isInteracting = false
                            }
                    )
            }
        })
        .onAppear {
            chartManager.recalculateChartDataPoints()
        }
        .sensoryFeedback(.selection, trigger: chartManager.selectedDate) { oldValue, newValue in
            
            ControlManager.shared.selectedBottomView == .transactions && oldValue != newValue
        }
    }
}

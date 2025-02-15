//
//  DynamicTitleParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct DynamicTitleParent: View {
    
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var controlManager: ControlManager
    
    
    var body: some View {
        
        VStack {
            if !chartManager.isInteracting {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        withAnimation {
                            Text("$\(financialEventManager.currentBalance, specifier: "%.2f")")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .contentTransition(.numericText(value: financialEventManager.currentBalance))
                        }
                        Text("\(Date.now, style: .date)")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                    if (controlManager.selectedChartView == .line) {
                        ViewThatFits {
                            Text("End of \(endOfNoun): $\(chartManager.endOfRangeBalance, specifier: "%.2f")")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("End of \(endOfNounShort): $\(chartManager.endOfRangeBalance, specifier: "%.2f")")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack(alignment: .center, spacing: 2) {
                            Image(systemName: chartManager.dollarChangePositive ? "arrow.up.right.circle" : "arrow.down.right.circle")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("$\(chartManager.dollarChange, specifier: "%.2f") \(thisNoun)")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .onAppear {
                            getPercentageChange()
                        }
                    }
                    
                }
                .padding(.horizontal)
                .onTapGesture {
                    timeManager.resetToCurrentPeriod()
                    chartManager.recalculateChartDataPoints()
                    financialEventManager.doUpdates()
                }
            } else {
                if let selectedDate = chartManager.selectedDate, let selectedBalance = chartManager.selectedBalance {
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(selectedDate, style: .date)")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("$\(selectedBalance, specifier: "%.2f")")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                controlManager.calculateMaxOffsets(geometry.size.width)
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            let screenWidth = UIScreen.main.bounds.width
            controlManager.screenWidth = screenWidth
        }
        .frame(height: 50)
        .offset(x: chartManager.isInteracting ? chartManager.scrubHorozontalOffset : 0)
        .onChange(of: timeManager.startDate) {
            getPercentageChange()
        }
    }
    
    
    private var endOfNoun: String {
        switch timeManager.timePeriod {
        case .week:
            return "week \(timeManager.startDate.formatted(.dateTime.week()))"
        case .fortnight:
            return "weeks \(timeManager.startDate.formatted(.dateTime.week())) & \(timeManager.endDate.formatted(.dateTime.week()))"
        case .month:
            return timeManager.startDate.formatted(.dateTime.month(.wide))
        case .year:
            return timeManager.startDate.formatted(.dateTime.year())
        case .custom:
            return timeManager.startDate.formatted(.dateTime.year())
        }
    }
    
    private var endOfNounShort: String {
        switch timeManager.timePeriod {
        case .week:
            return "week \(timeManager.startDate.formatted(.dateTime.week()))"
        case .fortnight:
            return "week \(timeManager.endDate.formatted(.dateTime.week()))"
        case .month:
            return timeManager.startDate.formatted(.dateTime.month(.abbreviated))
        case .year:
            return timeManager.startDate.formatted(.dateTime.year())
        case .custom:
            return timeManager.startDate.formatted(.dateTime.year())
        }
    }
    
    private var thisNoun: String {
        switch timeManager.timePeriod {
        case .week:
            return "in week #\(timeManager.startDate.formatted(.dateTime.week()))"
        case .fortnight:
            return "in week #\(timeManager.endDate.formatted(.dateTime.week()))"
        case .month:
            if Calendar.current.isDate(timeManager.startDate, equalTo: Date(), toGranularity: .year) {
                return "this \(timeManager.startDate.formatted(.dateTime.month(.abbreviated)))"
            } else {
                return "in \(timeManager.startDate.formatted(.dateTime.month(.abbreviated)))"
            }
        case .year:
            return "in \(timeManager.startDate.formatted(.dateTime.year()))"
        case .custom:
            return "in \(timeManager.startDate.formatted(.dateTime.year()))"
        }
    }
    
    
    private func getPercentageChange() {
        let occurrences = financialEventManager.visibleEventOccurences
        
        let totalCredits = occurrences
            .map { $0.transaction?.amount ?? 0 }
            .filter { $0 > 0 }
            .reduce(0, +)
        
        let totalDebits = occurrences
            .map { $0.transaction?.amount ?? 0 }
            .filter { $0 < 0 }
            .reduce(0, +)
        
        // For our chart, we use the positive value for debits.
        let absoluteDebits = abs(totalDebits)
        
        // Determine the maximum value of the Y axis.
        let maxValue = max(totalCredits, absoluteDebits)
        let minValue = min(totalCredits, absoluteDebits)
        
        chartManager.dollarChange = maxValue - minValue
        chartManager.dollarChangePositive = abs(totalCredits) > abs(totalDebits) ? true : false
    }

    
}

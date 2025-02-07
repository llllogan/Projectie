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
                }
                .padding(.horizontal)
                .onTapGesture {
                    timeManager.resetToCurrentPeriod()
                    chartManager.recalculateChartDataPoints()
                    financialEventManager.updateEventLists()
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
                }
            }
        }
        .frame(height: 50)
        .offset(x: chartManager.isInteracting ? chartManager.scrubHorozontalOffset : 0)
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

}

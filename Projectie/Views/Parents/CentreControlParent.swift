//
//  CentreControlParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct CentreControlParent: View {
    
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var controlManager: ControlManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var chartManager: ChartManager
    
    @State private var showCustomDateRangeSheet: Bool = false
    
    
    var body: some View {
        HStack {
            
            Menu {
                Picker("", selection: $controlManager.selectedBottomView) {
                    ForEach(BottomViewChoice.allCases, id: \.self) { choice in
                        Text(choice.rawValue.capitalized).tag(choice)
                            .lineLimit(1)
                    }
                }
            } label: {
                Button(action: { }) {
                    HStack(alignment: .center, spacing: 4) {
                        Text(controlManager.selectedBottomView.rawValue.capitalized)
                            .lineLimit(1)
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(systemName: "chevron.down")
                            .font(.body)
                            .fontWeight(.bold)
                    }
                }
                .buttonStyle(.plain)
                .tint(.primary)
            }

            Spacer()

            
            
            HStack(spacing: 6) {
                Text("Date Range")
                    .foregroundStyle(.secondary)
                Menu {
                    Picker("", selection: $timeManager.timePeriod) {
                        Text("Week").tag(TimePeriod.week)
                        Text("Fortnight").tag(TimePeriod.fortnight)
                        Text("Month").tag(TimePeriod.month)
                        Text("Year").tag(TimePeriod.year)
                        if (timeManager.timePeriod == .custom) {
                            Text("Custom").tag(TimePeriod.custom)
                        }
                    }
                    Button("Pick Custom Date Range") {
                        showCustomDateRangeSheet = true
                    }
                } label: {
                    Button("\(timeManager.timePeriod.rawValue.capitalized)") {}
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
            }
        }
        .sheet(isPresented: $showCustomDateRangeSheet) {
            CustomDateRangeSheet() { start, end in
                timeManager.timePeriod = .custom
                timeManager.startDate = start
                timeManager.endDate = end
                financialEventManager.doUpdates()
                chartManager.recalculateChartDataPoints()
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
        }
    }
}

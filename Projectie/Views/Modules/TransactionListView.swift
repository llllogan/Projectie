//
//  TransactionListView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 31/1/2025.
//

import SwiftUI
import Foundation

struct TransactionListView: View {
    
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var controlManager: ControlManager
    
    var groupedOccurrences: [(key: Date, value: [FinancialEventOccurence])]
    @State var allowedToAutoScroll: Bool = false
    
    @State private var scrollPosition: Date? = nil

    var body: some View {
        
        if(groupedOccurrences.isEmpty) {
            VStack {
                Spacer()
                Text("No transactions for this \(TimeManager.shared.timePeriod.rawValue)")
                    .foregroundStyle(.secondary)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                Spacer()
            }
        } else {
            
            ScrollViewReader { proxy in
                List {
                    ForEach(groupedOccurrences, id: \.key) { (date, occurrences) in
                        Section(header: Text(date, format: .dateTime.weekday(.wide).day().month(.wide))) {
                            transactionListDayOrganiser(occurenceList: occurrences)
                        }
                        .id(date)
                    }
                }
                .scrollPosition(id: $scrollPosition, anchor: .top)
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                .defaultScrollAnchor(.top)
                .onAppear {
                    if (allowedToAutoScroll) {
                        scrollToNearestDate(using: proxy)
                    }
                }
                .onChange(of: chartManager.selectedDate) { oldValue, newValue in
                    withAnimation(.easeOut(duration: 0.4)) {
                        proxy.scrollTo(newValue, anchor: .top)
                    }
                    
                }
            }
        }
    }
    
    
    private func scrollToNearestDate(using proxy: ScrollViewProxy) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: timeManager.startDate)
        let endDate = calendar.startOfDay(for: timeManager.endDate)
        
        // Only proceed if today is within the chart's date range.
        guard today >= startDate && today <= endDate else { return }
        
        // Get the list of available dates from the grouped occurrences.
        let availableDates = groupedOccurrences
            .map { calendar.startOfDay(for: $0.key) }
            .sorted()
        
        // Find the first date that is today or in the future.
        if let targetDate = availableDates.first(where: { $0 >= today }) {
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(targetDate, anchor: .top)
            }
        } else if let lastDate = availableDates.last {
            // Fallback: if no future date exists, scroll to the last date.
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(lastDate, anchor: .top)
            }
        }
    }
}

struct transactionListDayOrganiser: View {
    
    var occurenceList: [FinancialEventOccurence]
    
    var body: some View {
        
        ForEach(occurenceList) { occ in
            
            switch occ.type {
            case .transaction(let txn):
                TransactionListElement(
                    transaction: txn,
                    overrideDate: occ.date
                )
            case .reset(let rst):
                BalanceResetListElement(reset: rst)
            }
            
        }
        
    }
}

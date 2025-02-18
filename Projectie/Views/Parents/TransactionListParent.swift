//
//  TransactionListParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import SwiftUI
import SwiftData

struct TransactionListParent: View {
    
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var transactionManager: TransactionManager
    @EnvironmentObject private var balanceResetManager: BalanceResetManager
    @EnvironmentObject private var controlManager: ControlManager
    
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    @Query private var balanceResets: [BalanceReset]
    
    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
    @State private var centeredTransactionViewId: Int?
    @State private var overwriteSwipeIndexStart: Bool = true
    @State private var directionToMoveInTime: Int = 0
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    
    
    @State private var allowedToAutoScrollOnLoad: Bool = true
    
    @State private var isFirstLoadForTransactionList: Bool = true
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                TransactionListView(groupedOccurrences: financialEventManager.eventLintMinus2 ?? [])
                .id(-2)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListMinus1 ?? [])
                .id(-1)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventList ?? [], allowedToAutoScroll: allowedToAutoScrollOnLoad)
                .id(0)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListPlus1 ?? [])
                .id(1)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListPlus2 ?? [])
                .id(2)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                
            }
            .scrollTargetLayout()
        }
        .background(Color.niceBackground)
        .scrollTargetBehavior(.viewAligned)
        .defaultScrollAnchor(.center)
        .scrollPosition(id: $centeredTransactionViewId, anchor: .center)
        .scrollIndicators(.never)
        .onScrollPhaseChange { _, newPhase in
            
            if (newPhase == .idle) {
                
                ignoreChangeInCenteredTransactionViewId = true
                centeredTransactionViewId = 0
                overwriteSwipeIndexStart = true
                directionToMoveInTime = swipeEndIndex - swipeStartIndex
                timeManager.shiftPeriod(by: directionToMoveInTime)
                financialEventManager.doUpdates()
                chartManager.recalculateChartDataPoints()
                directionToMoveInTime = 0
                
                if (isFirstLoadForTransactionList) {
                    ignoreChangeInCenteredTransactionViewId = false
                    isFirstLoadForTransactionList = false
                }
            }
        }
        .onChange(of: transactions) { _, newValue in
            transactionManager.setTransactions(newValue)
            financialEventManager.doUpdates()
            chartManager.recalculateChartDataPoints()
        }
        .onChange(of: balanceResets) { _, newValue in
            balanceResetManager.setResets(newValue)
            financialEventManager.doUpdates()
            chartManager.recalculateChartDataPoints()
        }
        .onChange(of: centeredTransactionViewId ?? 0) { oldValue, newValue in
            handleChangeOfScrollView(oldValue: oldValue, newValue: newValue)
        }
        .onAppear {
            transactionManager.setTransactions(transactions)
            balanceResetManager.setResets(balanceResets)
            financialEventManager.doUpdates()
        }
        .sensoryFeedback(.impact, trigger: centeredTransactionViewId) { oldValue, newValue in
            oldValue != newValue && !ignoreChangeInCenteredTransactionViewId
        }
        .task(priority: .background) {
            let archiver = TransactionArchiver(modelContainer: context.container)
            await archiver.archive()
        }
    }
    
    
    
    func handleChangeOfScrollView(oldValue: Int, newValue: Int) {
        
        if (ignoreChangeInCenteredTransactionViewId) {
            ignoreChangeInCenteredTransactionViewId = false
            return
        }
        
        if (overwriteSwipeIndexStart) {
            swipeStartIndex = oldValue
            overwriteSwipeIndexStart = false
        }
        swipeEndIndex = newValue
    }

}

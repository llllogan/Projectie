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
    
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    @Query private var balanceResets: [BalanceReset]
    
    @State private var showManageTransactionSheet: Bool = false
    
    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
    @State private var centeredTransactionViewId: Int?
    @State private var overwriteSwipeIndexStart: Bool = true
    @State private var directionToMoveInTime: Int = 0
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    
    @State private var isFirstLoadForTransactionList: Bool = true
    
    @State private var selectedTransaction: Transaction?
    @State private var selectedTransactionInstanceDate: Date?
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                TransactionListView(groupedOccurrences: financialEventManager.eventLintMinus2 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                .id(-2)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListMinus1 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                .id(-1)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventList ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                .id(0)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListPlus1 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                .id(1)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                }
                TransactionListView(groupedOccurrences: financialEventManager.eventListPlus2 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
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
//        .sheet(isPresented: $showManageTransactionSheet) {
//            ManageTransactionSheet(transaction: selectedTransaction, instanceDate: selectedTransactionInstanceDate)
//                .presentationDragIndicator(.visible)
//        }
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
    }
    
    
    func handleTapOnTransactionListItem(transaction: Transaction?, instanceDate: Date?) {
        
        guard let transaction = transaction, let instanceDate = instanceDate else {
            print("Either transaction or instanceDate is nil. Exiting function.")
            return
        }
        
        selectedTransaction = transaction
        selectedTransactionInstanceDate = instanceDate
        
        showManageTransactionSheet = true
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

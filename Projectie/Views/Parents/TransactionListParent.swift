//
//  TransactionListParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import SwiftUI

struct TransactionListParent: View {
    
    @EnvironmentObject var timeManager: TimeManager
    
    @State private var showManageTransactionSheet: Bool = false
    
    @State private var transactionListMinus2: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListMinus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListToday: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus2: [(key: Date, value: [TransactionOccurrence])]?
    
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
                TransactionListView(groupedOccurrences: transactionListMinus2 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                    .id(-2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListMinus1 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                    .id(-1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListToday ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                    .id(0)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus1 ?? []) { transaction, date in
                    handleTapOnTransactionListItem(transaction: transaction, instanceDate: date)
                }
                    .id(1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus2 ?? []) { transaction, date in
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
        .scrollTargetBehavior(.viewAligned)
        .defaultScrollAnchor(.center)
        .scrollPosition(id: $centeredTransactionViewId, anchor: .center)
        .scrollIndicators(.never)
        .onScrollPhaseChange { _, newPhase in
            print("Scroll phase: \(newPhase)")
            if (newPhase == .idle) {
                ignoreChangeInCenteredTransactionViewId = true
                centeredTransactionViewId = 0
                overwriteSwipeIndexStart = true
                directionToMoveInTime = swipeEndIndex - swipeStartIndex
                timeManager.shiftPeriod(by: directionToMoveInTime)
//                populateTransactionLists()
//                recalculateChartDataPoints()
                directionToMoveInTime = 0
                
                if (isFirstLoadForTransactionList) {
                    ignoreChangeInCenteredTransactionViewId = false
                    isFirstLoadForTransactionList = false
                }
            }
        }
        .onChange(of: centeredTransactionViewId ?? 0) { oldValue, newValue in
            handleChangeOfScrollView(oldValue: oldValue, newValue: newValue)
        }
        .sheet(isPresented: $showManageTransactionSheet) {
            ManageTransactionSheet(transaction: selectedTransaction!, instanceDate: selectedTransactionInstanceDate)
                .presentationDragIndicator(.visible)
        }
    }
    
    
    func handleTapOnTransactionListItem(transaction: Transaction, instanceDate: Date) {
        selectedTransaction = transaction
        selectedTransactionInstanceDate = instanceDate
        
        showManageTransactionSheet = true
    }
    
    
    
    func handleChangeOfScrollView(oldValue: Int, newValue: Int) {
        
        if (ignoreChangeInCenteredTransactionViewId) {
            ignoreChangeInCenteredTransactionViewId = false
            return
        }
        
        print("Going from \(oldValue) to \(newValue). Moving \(newValue > oldValue ? "Forwards" : "Backwards")")
        
        if (overwriteSwipeIndexStart) {
            swipeStartIndex = oldValue
            overwriteSwipeIndexStart = false
        }
        swipeEndIndex = newValue
    }

}

//
//  GoalListParent.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct GoalListParent: View {
    
    @Environment(\.modelContext) private var context
    @Query private var goals: [Goal]
    
    @EnvironmentObject private var goalManager: GoalManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var chartManager: ChartManager
    @EnvironmentObject private var balanceResetManager: BalanceResetManager
    
    @State private var showAddGoalSheet: Bool = false
    
    
    var body: some View {
        
        if goalManager.goals.isEmpty {
            VStack(spacing: 30) {
                Spacer()
                Text("Nothing to see here")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(action: {
                    showAddGoalSheet = true
                }) {
                    Label("Add a Goal", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.secondary)
                
                Spacer()
            }
            .onAppear {
                goalManager.setGoals(goals)
            }
            .onChange(of: goals) { _, newValue in
                goalManager.setGoals(newValue)
//                handleGoalAddedToDisplayList()
            }
        } else {
            ScrollView(.vertical) {
                VStack {
                    ForEach(goalManager.goals, id: \.id) { goal in
                        GoalView(
                            goal: goal,
                            currentBalance: financialEventManager.currentBalance,
                            dateReached: earliestDateWhenGoalIsMet(goal.targetAmount),
                            goalsToDisplay: $chartManager.goalsToDisplayOnChart
                        )
                            .padding(.horizontal)
                            .padding(.bottom)
                            .padding(.top, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.niceGray)
                            )
                            .id(goal.id)
                            .scrollTransition { content, phase in
                                content
                                    .blur(radius: phase.isIdentity ? 0 : 2)
                            }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
            .padding(.top)
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.top)
            .background(Color.niceBackground)
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalSheet()
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                goalManager.setGoals(goals)
            }
            .onChange(of: goals) { _, newValue in
                goalManager.setGoals(newValue)
//                handleGoalAddedToDisplayList()
            }
        }
    }
    
    
    private func earliestDateWhenGoalIsMet(_ targetAmount: Double) -> Date? {
        let sortedOccurrences = financialEventManager.allEvents.sorted(by: { $0.date < $1.date })
        
        let latestResetBeforeNow = balanceResetManager.resets.first(where: { $0.date <= Date() })
        
        var runningBalance: Double
        var lastResetDate: Date
        
        if let reset = latestResetBeforeNow {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = 0
            lastResetDate = .distantPast
        }
        
        let preNowOccurrences = sortedOccurrences.filter { $0.date > lastResetDate && $0.date <= Date() }
        for occ in preNowOccurrences {
            runningBalance += occ.transaction?.amount ?? 0
        }
        
        if runningBalance >= targetAmount {
            return Date()
        }
        
        let futureOccurrences = sortedOccurrences.filter { $0.date > Date() }
        
        for occ in futureOccurrences {
            runningBalance += occ.transaction?.amount ?? 0
            
            if runningBalance >= targetAmount {
                return occ.date
            }
        }
        
        return nil
    }
}

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
            }
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalSheet()
            }
        } else {
            ScrollView(.vertical) {
                VStack {
                    ForEach(goalManager.goals, id: \.id) { goal in
                        GoalView(goal: goal, currentBalance: financialEventManager.currentBalance)
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
                                    .blur(radius: phase.isIdentity ? 0 : 0.5)
                            }
                    }
                    .scrollTargetLayout()
                }
            }
            .contentMargins(.vertical, 20)
            .scrollIndicators(.hidden)
            .padding(.horizontal)
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
}

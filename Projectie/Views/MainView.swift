//
//  MainProjectionView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI
import Charts
import SwiftData
import Foundation

struct MainView: View {
    
    // MARK: - App Storage (Persistent User Settings)
    @AppStorage("hasSetInitialBalance") private var hasSetInitialBalance: Bool = false
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var chartDataManager: ChartManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var controlManager: ControlManager
    @EnvironmentObject private var transactionManager: TransactionManager
    @EnvironmentObject private var balanceResetManager: BalanceResetManager
    @EnvironmentObject private var goalManager: GoalManager
    @EnvironmentObject private var accountManager: AccountManager
    
    
    @Query private var balanceResets: [BalanceReset]
    @Query private var goals: [Goal]
    @State private var showAddInitialBalanceSheet = false
    @State private var activeSheet: ActiveSheet?
    
    // MARK: - Main View
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                DynamicTitleParent()
                
                
                if (controlManager.selectedChartView == .line) {
                    LineGraphParent()
                        .frame(height: 200)
                } else {
                    BarGraphParent()
                        .frame(height: 200)
                }
                
                
                CentreControlParent()
                    .padding(.horizontal)
                
                
                if (controlManager.selectedBottomView == .goals) {
                    GoalListParent()
                } else {
                    TransactionListParent()
                }
                
            }
            .onAppear {
                
                accountManager.setContext(context)
                balanceResetManager.setResets(balanceResets)
                goalManager.setGoals(goals)
                
                withAnimation {
                    timeManager.calculateDates()
                }
                financialEventManager.doUpdates()
                chartDataManager.recalculateChartDataPoints()
                if (!hasSetInitialBalance && !ProcessInfo.processInfo.isRunningInXcodePreview) {
                    showAddInitialBalanceSheet = true
                }
            }
            .onChange(of: timeManager.timePeriod) { _, newValue in
                chartDataManager.recalculateChartDataPoints()
                financialEventManager.doUpdates()
            }
            .onChange(of: balanceResets) { _, newValue in
                balanceResetManager.setResets(newValue)
                chartDataManager.recalculateChartDataPoints()
                financialEventManager.doUpdates()
            }
            .onChange(of: goals) { _, newValue in
                goalManager.setGoals(newValue)
//                handleGoalAddedToDisplayList()
            }
            .sensoryFeedback(.selection, trigger: chartDataManager.selectedDate) { oldValue, newValue in
                oldValue != newValue
            }
            .sensoryFeedback(.impact, trigger: transactionManager.centeredTransactionViewId) { oldValue, newValue in
                oldValue != newValue && !transactionManager.ignoreChangeInCenteredTransactionViewId
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                    case .addTransaction:
                        AddTransactionSheet()
                            .presentationDragIndicator(.visible)
                    case .resetBalance:
                        ResetBalanceSheet()
                            .presentationDragIndicator(.visible)
                    case .addGoal:
                        AddGoalSheet()
                            .presentationDragIndicator(.visible)
                }
            }
            .fullScreenCover(isPresented: $showAddInitialBalanceSheet) {
                InitialBalanceSheet()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { activeSheet = .addTransaction }) {
                            Label("Add transaction", systemImage: "creditcard")
                        }
                        Button(action: { activeSheet = .addTransaction }) {
                            Label("Add interest", systemImage: "dollarsign.circle.fill")
                        }
                        .disabled(true)
                        Button(action: { activeSheet = .addGoal }) {
                            Label("Add goal", systemImage: "trophy")
                        }
                        Button(action: { activeSheet = .resetBalance }) {
                            Label("Correct Balance", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hue: 34/360, saturation: 0.99, brightness: 0.95))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
//                        Picker("Graph Style", selection: $controlManager.ChartViewChoice) {
//                            Label("Line", systemImage: "chart.xyaxis.line")
//                                .tag(ChartViewChoice.line)
//                            Label("Bar", systemImage: "chart.bar.xaxis")
//                                .tag(ChartViewChoice.bar)
//                        }
                        Button(action: {
                            squareLines.toggle()
                        }) {
                            Label("Line Interpolation Style", systemImage: "arrow.trianglehead.2.clockwise")
                        }
                        Button(action: {
                            hasSetInitialBalance = false
                            showAddInitialBalanceSheet = true
                        }) {
                            Label("Reset inital balance flag", systemImage: "slider.horizontal.2.arrow.trianglehead.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .tint(.primary)
                    }
                }
            }
        }
    }
}


// MARK: - Supporting Types

enum ActiveSheet: Identifiable {
    case addTransaction
    case resetBalance
    case addGoal
    
    var id: Int {
        UUID().hashValue
    }
}

extension ProcessInfo {
    var isRunningInXcodePreview: Bool {
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


#Preview {
    MainView()
}

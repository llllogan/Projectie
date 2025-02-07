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
//    @AppStorage("openingBalance") private var openingBalance = 0.0
    @AppStorage("hasSetInitialBalance") private var hasSetInitialBalance: Bool = false
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var chartDataManager: ChartManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var controlManager: ControlManager
    @EnvironmentObject private var transactionManager: TransactionManager
    
    // MARK: - Sheet & Modal Presentation States
//    @State private var showingAddTransactionSheet = false
//    @State private var showResetBalanceSheet = false
//    @State private var showManageTransactionSheet = false
//    @State private var showBottomToggle = true
    @State private var showAddInitialBalanceSheet = false
//    @State private var showCustomDatePicker: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    // MARK: - Chart & Time Frame States
//    @State private var selectedChartStyle: ChartViewStyle = .line
//    @State private var filteredChartData: [(date: Date, balance: Double)] = []
//    @State private var timeFrameOffset: Int = 0
//    @State private var directionToMoveInTime: Int = 0
    
    // MARK: - Transaction & Goal Selection & Navigation
//    @State var selectedBottomView: BottomViewChoice = .transactions
//    @State private var selectedBalance: Double? = nil
//    @State private var selectedDate: Date? = nil
//    @State private var selectedTransaction: Transaction?
//    @State private var selectedGoal: Goal?
//    @State private var centeredTransactionViewId: Int?
//    @State private var centeredGoalViewId: Int?
//    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
//    @State private var goalsToDisplay: [Goal] = []
//    @State private var goalPointMarks: [PointMark] = []
    
    // MARK: - Gesture & Interaction States
//    @State private var isInteracting: Bool = false
//    @State private var dragLocation: CGPoint = .zero
//    @State private var horizontalOffset: CGFloat = 0
//    @State private var swipeStartIndex: Int = 0
//    @State private var swipeEndIndex: Int = 0
//    @State private var overwriteSwipeIndexStart: Bool = true
    
    // MARK: - Miscellaneous
//    @State private var today: Date = Date()
//    @State private var isFirstLoadForTransactionList: Bool = true
    

    
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
                
                
                if (controlManager.selectedBottomView == .goals) {
                    GoalListParent()
                } else {
                    TransactionListParent()
                }
                
            }
            .onAppear {
                withAnimation {
                    timeManager.calculateDates()
                }
                chartDataManager.recalculateChartDataPoints()
                financialEventManager.updateEventLists()
                if (!hasSetInitialBalance && !ProcessInfo.processInfo.isRunningInXcodePreview) {
                    showAddInitialBalanceSheet = true
                }
            }
            .onChange(of: timeManager.timePeriod) { _, newValue in
                chartDataManager.recalculateChartDataPoints()
                financialEventManager.updateEventLists()
            }
//            .onChange(of: transactions) { _, newValue in
//                chartDataManager.recalculateChartDataPoints()
//                financialEventManager.updateEventLists()
//            }
//            .onChange(of: allBalanceResets) { _, newValue in
//                chartDataManager.recalculateChartDataPoints()
//                financialEventManager.updateEventLists()
//            }
//            .onChange(of: goalsToDisplay) { _, newValue in
//                handleGoalAddedToDisplayList()
//            }
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
    

    
    
    
    // MARK: - Helper Function
    
    
//    func handleGoalAddedToDisplayList() {
//        
//        var goalPointMarks: [(amount: Double, date: Date)] = []
//        
//        if (goalsToDisplay.isEmpty) { return }
//        
//        for goal in goalsToDisplay {
//
//            if let achievementDate = earliestDateWhenGoalIsMet(goal.targetAmount) {
//                goalPointMarks.append( (amount: goal.targetAmount, date: achievementDate) )
//            }
//        }
//        
//        let sortedGoalPointMarks = goalPointMarks.sorted { $0.date < $1.date }
//        
//        timeManager.startDate = sortedGoalPointMarks.first!.date.advanced(by: -86400)
//        timeManager.endDate = sortedGoalPointMarks.last!.date.advanced(by: 86400)
//        
//        for mark in goalPointMarks {
//            
//            self.goalPointMarks.append(
//                PointMark(
//                    x: .value("Date", mark.date),
//                    y: .value("Amount", mark.amount)
//                )
//            )
//            
//        }
//        
//    }
    
    

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

enum RangeOffset: Int {
    case minus3 = -3
    case minus2 = -2
    case minus1 = -1
    case none   =  0
    case plus1  =  1
    case plus2  =  2
    case plus3  =  3
}

extension ProcessInfo {
    var isRunningInXcodePreview: Bool {
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


#Preview {
    MainView()
}

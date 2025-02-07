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
    @AppStorage("openingBalance") private var openingBalance = 0.0
    @AppStorage("hasSetInitialBalance") private var hasSetInitialBalance: Bool = false
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var chartDataManager: ChartManager
    @EnvironmentObject var timeManager: TimeManager
    
    // MARK: - Swift Data Queries
    @Query(sort: \Transaction.date, order: .forward)
    private var transactions: [Transaction]
    
    @Query(sort: \BalanceReset.date, order: .reverse)
    private var allBalanceResets: [BalanceReset]
    
    @Query(sort: \Goal.createdDate, order: .forward)
    private var goals: [Goal]
    
    // MARK: - Sheet & Modal Presentation States
    @State private var showingAddTransactionSheet = false
    @State private var showResetBalanceSheet = false
    @State private var showManageTransactionSheet = false
    @State private var showBottomToggle = true
    @State private var showAddInitialBalanceSheet = false
    @State private var showCustomDatePicker: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    // MARK: - Chart & Time Frame States
    @State private var selectedChartStyle: ChartViewStyle = .line
    @State private var filteredChartData: [(date: Date, balance: Double)] = []
    @State private var timeFrameOffset: Int = 0
    @State private var directionToMoveInTime: Int = 0
    
    // MARK: - Transaction & Goal Selection & Navigation
    @State private var selectedBottomView: BottomViewChoice = .transactions
    @State private var selectedBalance: Double? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedTransaction: Transaction?
    @State private var selectedGoal: Goal?
    @State private var centeredTransactionViewId: Int?
    @State private var centeredGoalViewId: Int?
    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
    @State private var goalsToDisplay: [Goal] = []
    @State private var goalPointMarks: [PointMark] = []
    
    // MARK: - Gesture & Interaction States
    @State private var isInteracting: Bool = false
    @State private var dragLocation: CGPoint = .zero
    @State private var horizontalOffset: CGFloat = 0
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    @State private var overwriteSwipeIndexStart: Bool = true
    
    // MARK: - Miscellaneous
    @State private var today: Date = Date()
    @State private var isFirstLoadForTransactionList: Bool = true
    

    
    // MARK: - Main View
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                dynamicTitle
                
                chart
                    .frame(height: 200)
                
                chartControlls
                
                bottomList
                
            }
            .onAppear {
                today = Date()
                withAnimation {
                    timeManager.calculateDates()
                }
                chartDataManager.recalculateChartDataPoints()
                populateTransactionLists()
                if (!hasSetInitialBalance && !ProcessInfo.processInfo.isRunningInXcodePreview) {
                    showAddInitialBalanceSheet = true
                }
            }
            .onChange(of: timeManager.timePeriod) { _, newValue in
                recalculateChartDataPoints()
                populateTransactionLists()
            }
            .onChange(of: transactions) { _, newValue in
                recalculateChartDataPoints()
                populateTransactionLists()
            }
            .onChange(of: allBalanceResets) { _, newValue in
                recalculateChartDataPoints()
                populateTransactionLists()
            }
//            .onChange(of: goalsToDisplay) { _, newValue in
//                handleGoalAddedToDisplayList()
//            }
            .sensoryFeedback(.selection, trigger: selectedDate) { oldValue, newValue in
                oldValue != newValue
            }
            .sensoryFeedback(.impact, trigger: centeredTransactionViewId) { oldValue, newValue in
                oldValue != newValue && !ignoreChangeInCenteredTransactionViewId
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                    case .addTransaction:
                        AddTransactionSheet()
                            .presentationDragIndicator(.visible)
                    case .resetBalance:
                        ResetBalanceSheet()
                            .presentationDragIndicator(.visible)
                    case .manageTransaction(let transaction, let date):
                        ManageTransactionSheet(transaction: transaction, instanceDate: date)
                            .presentationDragIndicator(.visible)
                    case .addGoal:
                        AddGoalSheet()
                            .presentationDragIndicator(.visible)
                    case .customDateRange:
                        CustomDateRangeSheet() { start, end in
                            timeManager.timePeriod = .custom
                            timeManager.startDate = start
                            timeManager.endDate = end
                            recalculateChartDataPoints()
                            populateTransactionLists()
                        }
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
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
                        Picker("Graph Style", selection: $selectedChartStyle) {
                            Label("Line", systemImage: "chart.xyaxis.line")
                                .tag(ChartViewStyle.line)
                            Label("Bar", systemImage: "chart.bar.xaxis")
                                .tag(ChartViewStyle.bar)
                        }
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
    
    
    
    // MARK: - Child Views
    
    
    
    // MARK: - Dynamic Title
    private var dynamicTitle: some View {
        
        VStack {
            if !isInteracting {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        withAnimation {
                            Text("$\(currentBalance, specifier: "%.2f")")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .contentTransition(.numericText(value: currentBalance))
                        }
                        Text("\(Date.now, style: .date)")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    ViewThatFits {
                        Text("End of \(endOfNoun): $\(endOfRangeBalance, specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("End of \(endOfNounShort): $\(endOfRangeBalance, specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    timeManager.resetToCurrentPeriod()
                    recalculateChartDataPoints()
                    populateTransactionLists()
                }
            } else {
                if let selectedDate = selectedDate, let selectedBalance = selectedBalance {
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
        .offset(x: isInteracting ? horizontalOffset : 0)
    }
    
    
    // MARK: - Chart Parent
    private var chart: some View {
        // TODO: make this look cool with animations
        
        return Section {
            if (selectedChartStyle == .line) {
                chartLine
            } else {
                chartBar(occurrences: visibleOccurrencesForPeriod)
            }
        }
    }
    
    
    
    // MARK: - Chart (line)
    private var chartLine: some View {
        let allBalances = filteredChartData.map { $0.balance }
        
        let minBalance = allBalances.min() ?? 0
        let maxBalance = allBalances.max() ?? 0
        let chartMin = minBalance - (minBalance / 90)
        let chartMax = maxBalance + (maxBalance / 90)
        
        let today = Date()
        let startDate = timeManager.startDate
        let endDate = timeManager.endDate
        let showTodayLine = (today >= startDate && today <= endDate)
        
        return Chart {
            if !isInteracting && showTodayLine {
                RuleMark(x: .value("Today", today))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
            
            if isInteracting, let selectedDate = selectedDate, let selectedBalance = selectedBalance {
                // White vertical line
                RuleMark(x: .value("Selected X", selectedDate))
                    .foregroundStyle(Color.whiteInDarkBlackInLight)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                
                // White circle at the intersection
                PointMark(
                    x: .value("Selected X", selectedDate),
                    y: .value("Selected Y", selectedBalance)
                )
                .symbol(.circle)
                // Adjust symbolSize to taste
                .symbolSize(40)
                .foregroundStyle(Color.whiteInDarkBlackInLight)
            }
            
//            if selectedBottomView == .goals {
//                print("Hello")
//            }
            
            ForEach(filteredChartData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(Color(hue: 34/360, saturation: 0.99, brightness: 0.95))
                .interpolationMethod(squareLines ? .stepEnd : .linear)
                
                AreaMark(
                    x: .value("Date", dataPoint.date),
                    yStart: .value("Baseline", chartMin),
                    yEnd: .value("Balance", dataPoint.balance)
                )
                .interpolationMethod(squareLines ? .stepEnd : .linear)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 34/360, saturation: 0.99, brightness: 0.95).opacity(0.5),
                            Color(hue: 34/360, saturation: 0.99, brightness: 0.95).opacity(0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartYAxis {
            AxisMarks(
                position: .leading,
                values: .automatic(desiredCount: 4)
            )
        }
        .chartYScale(domain: chartMin...chartMax)
        .frame(height: 180)
        .padding()
        .chartOverlay(content: { proxy in
            GeometryReader { geoProxy in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                
                                if (selectedBottomView == .transactions) {
                                    isInteracting = true
                                }
                                
                                let origin = geoProxy[proxy.plotFrame!].origin
                                let locationXOnChart = value.location.x - origin.x
                                
                                let screenWidth = geoProxy.size.width
                                let distanceToLeft = value.location.x
                                
                                self.horizontalOffset = distanceToLeft - (screenWidth / 2)
                                
                                if let date: Date = proxy.value(atX: locationXOnChart) {
                                    // Find the closest data point in filteredChartData
                                    if let closest = filteredChartData.min(by: {
                                        abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                    }) {
                                        self.selectedDate = closest.date
                                        self.selectedBalance = closest.balance
                                    }
                                }
                            }
                            .onEnded { _ in
                                isInteracting = false
                            }
                    )
            }
        })
    }
    
    
    // MARK: - Chart (bar)
    struct chartBar: View {
        var occurrences: [FinancialEventOccurence]

        var body: some View {
            let totalCredits = occurrences
                .map { $0.transaction?.amount ?? 0 }
                .filter { $0 > 0 }
                .reduce(0, +)
            
            let totalDebits = occurrences
                .map { $0.transaction?.amount ?? 0 }
                .filter { $0 < 0 }
                .reduce(0, +)

            Chart {
                BarMark(
                    x: .value("Type", "Credits"),
                    y: .value("Amount", totalCredits)
                )
                .foregroundStyle(.green)
                
                BarMark(
                    x: .value("Type", "Debits"),
                    y: .value("Amount", abs(totalDebits))
                )
                .foregroundStyle(.red)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
        }
    }
    
    
    // MARK: - Chart Controlls
    private var chartControlls: some View {
        
        HStack {
            
            Menu {
                Picker("", selection: $selectedBottomView) {
                    ForEach(BottomViewChoice.allCases, id: \.self) { choice in
                        Text(choice.rawValue.capitalized).tag(choice)
                            .lineLimit(1)
                    }
                }
            } label: {
                Button(action: { }) {
                    HStack(alignment: .center, spacing: 4) {
                        Text(selectedBottomView.rawValue.capitalized)
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
                        activeSheet = .customDateRange
                    }
                } label: {
                    Button("\(timeManager.timePeriod.rawValue.capitalized)") {}
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
            }
            
            
        }
        .padding(.horizontal)
    }
    
    
    
    // MARK: - Bottom List Parent
    private var bottomList: some View {
        
        return Section {
            if (selectedBottomView == .goals) {
                goalList
            } else {
                TransactionListParent()
            }
        }
        
    }

    
    // MARK: - Goal List
    private var goalList: some View {
        
        Section {
            if goals.isEmpty {
                VStack(spacing: 30) {
                    Spacer()
                    Text("Nothing to see here")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(action: {
                        activeSheet = .addGoal
                    }) {
                        Label("Add a Goal", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(goals, id: \.id) { goal in
                            GoalView(goal: goal, currentBalance: currentBalance, dateReached: earliestDateWhenGoalIsMet(goal.targetAmount), goalsToDisplay: $goalsToDisplay)
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
            }
        }
    }
    
    
    
    
    
    
    // MARK: - Computed Properties
    
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
    
    
    private var mostRecentReset: BalanceReset? {
        allBalanceResets.first
    }
    
    
    private var currentBalance: Double {
        guard let reset = mostRecentReset else {
            // If no reset exists, fall back to using openingBalance
            return openingBalance + sumOfAllTransactionsUpTo(Date())
        }
        
        let baseline = reset.balanceAtReset
        let resetDate = reset.date
        
        let sumAfterReset = allOccurrences
            .filter { $0.date > resetDate && $0.date <= Date() }
            .reduce(0) { $0 + ($1.transaction?.amount ?? 0) }
        
        return baseline + sumAfterReset
    }
    
    
    private var endOfRangeBalance: Double {
        guard let lastDataPoint = filteredChartData.last else { return 0.0 }
        return lastDataPoint.balance
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
    
    
    func ordinalDayString(from date: Date) -> String {
        // Extract the day component from the date
        let day = Calendar.current.component(.day, from: date)
        
        // Create and configure the NumberFormatter for ordinal numbers
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        
        // Return the formatted string (or fallback to the plain day number)
        return formatter.string(from: NSNumber(value: day)) ?? "\(day)"
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
    
    
    private func recalculateChartDataPoints() {
        
        let calendar = Calendar.current

        let sortedTransactions = allOccurrences.sorted { $0.date < $1.date }
        let sortedResets = allBalanceResets.sorted { $0.date < $1.date }

        let latestResetBeforeStart = sortedResets.last(where: { $0.date <= timeManager.startDate })

        var runningBalance: Double
        var lastResetDate: Date

        if let reset = latestResetBeforeStart {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = openingBalance
            lastResetDate = Date.distantPast
        }

        let transactionsBeforeStart = sortedTransactions.filter { $0.date > lastResetDate && $0.date < timeManager.startDate }
        for txn in transactionsBeforeStart {
            runningBalance += txn.transaction?.amount ?? 0
        }

        let resetsWithinTimeFrame = sortedResets.filter { $0.date >= timeManager.startDate && $0.date <= timeManager.endDate }
        let transactionsWithinTimeFrame = sortedTransactions.filter { $0.date >= timeManager.startDate && $0.date <= timeManager.endDate }
        
        let transactionsByDay = Dictionary(
            grouping: transactionsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }

        let resetsByDay = Dictionary(
            grouping: resetsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }

        var dataPoints: [(date: Date, balance: Double)] = []
        var currentDate = timeManager.startDate
        let endDate = timeManager.endDate

        while currentDate <= endDate {
            // Apply any resets on this day
            if let todaysResets = resetsByDay[currentDate] {
                for reset in todaysResets.sorted(by: { $0.date < $1.date }) {
                    runningBalance = reset.balanceAtReset
                }
            }

            if let todaysTransactions = transactionsByDay[currentDate] {
                for txn in todaysTransactions {
                    runningBalance += txn.transaction?.amount ?? 0
                }
            }

            dataPoints.append((date: currentDate, balance: runningBalance))

            // Move to the next day
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        filteredChartData = dataPoints
    }

    
    private func earliestDateWhenGoalIsMet(_ targetAmount: Double) -> Date? {
        let sortedOccurrences = allOccurrences.sorted(by: { $0.date < $1.date })
        
        let latestResetBeforeNow = allBalanceResets.first(where: { $0.date <= Date() })
        
        var runningBalance: Double
        var lastResetDate: Date
        
        if let reset = latestResetBeforeNow {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = openingBalance
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
    
    
    private func sumOfAllTransactionsUpTo(_ date: Date) -> Double {
        allOccurrences
        
            .filter { $0.date <= date }
            .reduce(0) { $0 + $1.transaction!.amount }
    }
    
//    private func changeDate(by value: Int) {
//        switch selectedTimeFrame {
//        case .week:
//            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentStartDate) {
//                timeManager.startDate = newDate
//            }
//        case .month:
//            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentStartDate) {
//                timeManager.startDate = newDate
//            }
//        case .year:
//            if let newDate = Calendar.current.date(byAdding: .year, value: value, to: currentStartDate) {
//                timeManager.startDate = newDate
//            }
//        }
//        recalculateChartDataPoints()
//    }
}


// MARK: - Supporting Types

enum BottomViewChoice: String, CaseIterable {
    case transactions
    case goals
}

enum TimeFrame: String, CaseIterable {
    case week
    case month
    case year
}

enum ChartViewStyle: String, CaseIterable {
    case line
    case bar
}

enum ActiveSheet: Identifiable {
    case addTransaction
    case resetBalance
    case manageTransaction(Transaction, Date)
    case addGoal
    case customDateRange
    
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

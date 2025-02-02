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
    @AppStorage("openingBalance") private var openingBalance = 0.0
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Transaction.date, order: .forward) private var transactions: [Transaction]
    @Query(sort: \BalanceReset.date, order: .reverse) private var allBalanceResets: [BalanceReset]
    @Query(sort: \Goal.createdDate, order: .forward) private var goals: [Goal]
    
    @State private var showingAddTransactionSheet = false
    @State private var showResetBalanceSheet: Bool = false
    @State private var showManageTransactionSheet: Bool = false
    @State private var showBottomToggle: Bool = true
    
    @State private var selectedChartStyle: ChartViewStyle = .line
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var selectedBottomView: BottomViewChoice = .transactions
    @State private var selectedBalance: Double? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedTransaction: Transaction?
    
    @State private var isInteracting: Bool = false
    
    @State private var currentStartDate: Date = Date()
    
    @State private var dragLocation: CGPoint = .zero

    @State private var horizontalOffset: CGFloat = 0
    
    @State private var activeSheet: ActiveSheet?
    
    @State private var filteredChartData: [(date: Date, balance: Double)] = []
    
    @State private var centeredTransactionViewId: Int?
    
    
    @State private var transactionListMinus2: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListMinus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListToday: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus2: [(key: Date, value: [TransactionOccurrence])]?
    
    
    @State private var today: Date = Date()
    @State private var timeFrameOffset: Int = 0
    @State private var directionToMoveInTime: Int = 0
    
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    @State private var overwriteSwipeIndexStart: Bool = true
    
    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
    
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
                updateCurrentStartDate()
                recalculateChartDataPoints()
                populateTransactionLists()
            }
            .onChange(of: selectedTimeFrame) { _, newValue in
                updateCurrentStartDate()
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { activeSheet = .addTransaction }) {
                            Label("Add transaction", systemImage: "creditcard")
                        }
                        Button(action: { activeSheet = .addTransaction }) {
                            Label("Add interest", systemImage: "dollarsign.circle.fill")
                        }
                        Button(action: { activeSheet = .addGoal }) {
                            Label("Add goal", systemImage: "trophy")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: { activeSheet = .resetBalance }) {
                            Label("Correct Balance", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                        }
                        Picker("Graph Style", selection: $selectedChartStyle) {
                            Label("Line", systemImage: "chart.xyaxis.line")
                                .tag(ChartViewStyle.line)
                            Label("Bar", systemImage: "chart.bar.xaxis")
                                .tag(ChartViewStyle.bar)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .tint(.primary)
                    }
                }

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
                        Text("$\(currentBalance, specifier: "%.2f")")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
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
        
        let chartMin = minBalance - (minBalance / 10)
        let chartMax = maxBalance + (maxBalance / 10)
        
        let today = Date()
        let startDate = currentStartDate
        let endDate = endDateForCurrentTimeFrame
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
            
            ForEach(filteredChartData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
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
                                isInteracting = true
                                
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
        var occurrences: [TransactionOccurrence]

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
                    Picker("", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { frame in
                            Text(frame.rawValue.capitalized).tag(frame)
                                .lineLimit(1)
                        }
                    }
                } label: {
                    Button(action: { }) {
                        Text(selectedTimeFrame.rawValue.capitalized)
                            .lineLimit(1)
                    }
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
                transactionList
            }
        }
        
    }
    
    
    // MARK: - Transaction List
    private var transactionList: some View {

        ScrollView(.horizontal) {
            HStack {
                TransactionListView(groupedOccurrences: transactionListMinus2 ?? [], activeSheet: $activeSheet)
                    .id(-2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                TransactionListView(groupedOccurrences: transactionListMinus1 ?? [], activeSheet: $activeSheet)
                    .id(-1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                TransactionListView(groupedOccurrences: transactionListToday ?? [], activeSheet: $activeSheet)
                    .id(0)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus1 ?? [], activeSheet: $activeSheet)
                    .id(1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus2 ?? [], activeSheet: $activeSheet)
                    .id(2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
//                            .blur(radius: phase.isIdentity ? 0 : 20)
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
                changeDate(by: directionToMoveInTime)
                populateTransactionLists()
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
        
    }

    
    // MARK: - Goal List
    private var goalList: some View {
        List(goals) { goal in
            VStack(alignment: .leading) {
                Text(goal.title)
                    .font(.headline)
                
                let dateReached = earliestDateWhenGoalIsMet(goal.targetAmount)
                if let dateReached = dateReached {
                    Text("Reached by: \(dateReached, style: .date)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Goal Not Met")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    
    
    
    
    
    // MARK: - Computed Properties
    
    private var endOfNoun: String {
        switch selectedTimeFrame {
        case .week:
            return "week \(currentStartDate.formatted(.dateTime.week()))"
        case .month:
            return currentStartDate.formatted(.dateTime.month(.wide))
        case .year:
            return currentStartDate.formatted(.dateTime.year())
        }
    }
    
    private var endOfNounShort: String {
        switch selectedTimeFrame {
        case .week:
            return "week \(currentStartDate.formatted(.dateTime.week()))"
        case .month:
            return currentStartDate.formatted(.dateTime.month(.abbreviated))
        case .year:
            return currentStartDate.formatted(.dateTime.year())
        }
    }
    
    
    private var mostRecentReset: BalanceReset? {
        allBalanceResets.first
    }
    
    
    private var allOccurrences: [TransactionOccurrence] {
        let transactionOccurrences = transactions.flatMap { txn in
            if txn.isRecurring {
                return txn.recurrenceDates.compactMap { date in
                    TransactionOccurrence(type: .transaction(txn), recurringTransactionDate: date)
                }
            } else {
                return [TransactionOccurrence(type: .transaction(txn))]
            }
        }
        
        let otherTypeOccurrences = allBalanceResets.flatMap { rst in
            return [TransactionOccurrence(type: .reset(rst))]
        }
        
        return transactionOccurrences + otherTypeOccurrences
    }
    
    
    private var visibleOccurrencesForPeriod: [TransactionOccurrence] {
        allOccurrences.filter {
            $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame
        }
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
    
    
    private var endDateForCurrentTimeFrame: Date {
        switch selectedTimeFrame {
        case .week:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentStartDate) ?? currentStartDate
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: currentStartDate) ?? currentStartDate
        case .year:
            return Calendar.current.date(byAdding: .year, value: 1, to: currentStartDate) ?? currentStartDate
        }
    }
    
    
    
    
    
    
    // MARK: - Helper Function
    
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
    
    
    func populateTransactionLists() {
        
        transactionListMinus2 = groupedOccurrences(rangeOffset: .minus2)
        transactionListMinus1 = groupedOccurrences(rangeOffset: .minus1)
        transactionListToday = groupedOccurrences(rangeOffset: .none)
        transactionListPlus1 = groupedOccurrences(rangeOffset: .plus1)
        transactionListPlus2 = groupedOccurrences(rangeOffset: .plus2)
        
    }
    
    
    func groupedOccurrences(rangeOffset: RangeOffset) -> [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current
        
        // 1. Convert the enum into an integer offset
        let offsetValue = rangeOffset.rawValue

        // 2. Determine the “base” start date — e.g., currentStartDate
        //    and your “base” end date — e.g., endDateForCurrentTimeFrame.
        //    (The code below references variables from your existing code, like selectedTimeFrame.)
        
        // Existing “currentStartDate” for the 'none' offset
        var offsetStartDate = currentStartDate
        // Existing “endDateForCurrentTimeFrame” for the 'none' offset
        var offsetEndDate   = endDateForCurrentTimeFrame

        // 3. Shift the start/end date based on your selectedTimeFrame + offsetValue
        switch selectedTimeFrame {
        case .week:
            // Move the start date by N weeks
            if let newStart = calendar.date(byAdding: .weekOfYear, value: offsetValue, to: currentStartDate) {
                offsetStartDate = newStart
            }
            
            // Then recalculate the end date from that new start date
            // For example: 1 week from offsetStartDate
            if let newEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: offsetStartDate) {
                offsetEndDate = newEnd
            }

        case .month:
            if let newStart = calendar.date(byAdding: .month, value: offsetValue, to: currentStartDate) {
                offsetStartDate = newStart
            }
            // 1 month from offsetStartDate
            if let newEnd = calendar.date(byAdding: .month, value: 1, to: offsetStartDate) {
                offsetEndDate = newEnd
            }

        case .year:
            if let newStart = calendar.date(byAdding: .year, value: offsetValue, to: currentStartDate) {
                offsetStartDate = newStart
            }
            // 1 year from offsetStartDate
            if let newEnd = calendar.date(byAdding: .year, value: 1, to: offsetStartDate) {
                offsetEndDate = newEnd
            }
        }

        // 4. Filter occurrences that lie within this shifted range
        let visibleOccurrences = allOccurrences.filter {
            $0.date >= offsetStartDate && $0.date <= offsetEndDate
        }

        // 5. Group by start of day
        let grouped = Dictionary(grouping: visibleOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }

        // 6. Return them sorted by day
        return grouped
            .sorted { $0.key < $1.key }
    }
    
    
    
    private func recalculateChartDataPoints() {
        
        let calendar = Calendar.current

        let sortedTransactions = allOccurrences.sorted { $0.date < $1.date }
        let sortedResets = allBalanceResets.sorted { $0.date < $1.date }

        let latestResetBeforeStart = sortedResets.last(where: { $0.date <= currentStartDate })

        var runningBalance: Double
        var lastResetDate: Date

        if let reset = latestResetBeforeStart {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = openingBalance
            lastResetDate = Date.distantPast
        }

        let transactionsBeforeStart = sortedTransactions.filter { $0.date > lastResetDate && $0.date < currentStartDate }
        for txn in transactionsBeforeStart {
            runningBalance += txn.transaction?.amount ?? 0
        }

        let resetsWithinTimeFrame = sortedResets.filter { $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame }
        let transactionsWithinTimeFrame = sortedTransactions.filter { $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame }
        
        let transactionsByDay = Dictionary(
            grouping: transactionsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }

        let resetsByDay = Dictionary(
            grouping: resetsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }

        var dataPoints: [(date: Date, balance: Double)] = []
        var currentDate = currentStartDate
        let endDate = endDateForCurrentTimeFrame

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
    
    private func changeDate(by value: Int) {
        switch selectedTimeFrame {
        case .week:
            if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentStartDate) {
                currentStartDate = newDate
            }
        case .month:
            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentStartDate) {
                currentStartDate = newDate
            }
        case .year:
            if let newDate = Calendar.current.date(byAdding: .year, value: value, to: currentStartDate) {
                currentStartDate = newDate
            }
        }
        recalculateChartDataPoints()
    }
    
    private func updateCurrentStartDate() {
        let calendar = Calendar.current
        switch selectedTimeFrame {
        case .week:
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start {
                currentStartDate = weekStart
            }
        case .month:
            if let monthStart = calendar.dateInterval(of: .month, for: Date())?.start {
                currentStartDate = monthStart
            }
        case .year:
            if let yearStart = calendar.dateInterval(of: .year, for: Date())?.start {
                currentStartDate = yearStart
            }
        }
    }
}


// MARK: - Supporting Types

struct TransactionOccurrence: Identifiable {
    
    let type: OccurrenceType
    let recurringTransactionDate: Date?
    
    init(type: OccurrenceType, recurringTransactionDate: Date? = nil) {
        self.type = type
        self.recurringTransactionDate = recurringTransactionDate
    }
    
    var transaction: Transaction? {
        switch type {
        case .transaction(let transaction):
            return transaction
        case .reset(_):
            return nil
        }
    }
    
    var date: Date {
        switch type {
        case .transaction(let transaction):
            return recurringTransactionDate ?? transaction.date
        case .reset(let balanceReset):
            return balanceReset.date
        }
    }
    
    var id: String {
        switch type {
        case .transaction(let transaction):
            return "\(transaction.id)-\(date.timeIntervalSince1970)"
        case .reset(let balanceReset):
            return "\(balanceReset.id)-\(date.timeIntervalSince1970)"
        }

    }
}

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

enum OccurrenceType {
    case transaction(Transaction)
    case reset(BalanceReset)
}


#Preview {
    MainView()
}

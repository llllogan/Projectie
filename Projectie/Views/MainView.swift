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
    
    // MARK: - Swift Data Queries
    @Query(sort: \Transaction.date, order: .forward)
    private var transactions: [Transaction]
    
    @Query(sort: \BalanceReset.date, order: .reverse)
    private var allBalanceResets: [BalanceReset]
    
    @Query(sort: \Goal.createdDate, order: .forward)
    private var goals: [Goal]
    
    // MARK: - Observed Objects
    @ObservedObject private var timeManager = TimeManager.shared
    
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
    
    // MARK: - Transaction Selection & Navigation
    @State private var selectedBottomView: BottomViewChoice = .transactions
    @State private var selectedBalance: Double? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedTransaction: Transaction?
    @State private var centeredTransactionViewId: Int?
    @State private var ignoreChangeInCenteredTransactionViewId: Bool = false
    
    // MARK: - Gesture & Interaction States
    @State private var isInteracting: Bool = false
    @State private var dragLocation: CGPoint = .zero
    @State private var horizontalOffset: CGFloat = 0
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    @State private var overwriteSwipeIndexStart: Bool = true
    
    // MARK: - Transaction Lists by Date Groups
    @State private var transactionListMinus2: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListMinus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListToday: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus1: [(key: Date, value: [TransactionOccurrence])]?
    @State private var transactionListPlus2: [(key: Date, value: [TransactionOccurrence])]?
    
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
                withAnimation {
                    timeManager.calculateDates()
                }
                recalculateChartDataPoints()
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
        
        var spanningSeconds: Double = 0
        switch timeManager.timePeriod {
        case .week:
            spanningSeconds = 86400
        case .month:
            spanningSeconds = 86400 * 7
        case .year:
            spanningSeconds = 86400 * 91
        default:
            spanningSeconds = 86400
        }
        
        var xAxisDates: [Date] = stride(from: timeManager.startDate, to: timeManager.endDate, by: spanningSeconds).map { $0 }
        
        if (showTodayLine && !isInteracting) {
            xAxisDates.append(today)
        }
        
        xAxisDates.sort { $0 < $1 }
        
        var filteredXAxisDates: [Date] = []
        var itteration: Int = 0

        for date in xAxisDates {
            
            if (filteredXAxisDates.isEmpty) {
                filteredXAxisDates.append(date)
                continue
            }
            
            let timeSinceLastDate: TimeInterval = date.timeIntervalSince(filteredXAxisDates.last!)
            
            if (timeSinceLastDate < spanningSeconds) {
                if (date == today) {
                    filteredXAxisDates.append(date)
                }
            } else {
                filteredXAxisDates.append(date)
            }

            itteration += 1
        }
        
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
        .chartXAxis {
            AxisMarks(values: filteredXAxisDates) { value in
                if let date = value.as(Date.self) {
                    
                    if (date != today) {
                        AxisGridLine()
                        AxisTick()
                    }

                    
                    AxisValueLabel(horizontalSpacing: date == today ? -12 : 2) {
                        
                        if (date == today) {
                            Text(timeManager.timePeriod == .week ? "Now" :"Today")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            if (timeManager.timePeriod == .year) {
                                Text(date, format: .dateTime.month())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(ordinalDayString(from: date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            AxisMarks(values: xAxisDates) { value in
                if let date = value.as(Date.self) {
                    if (date != today) {
                        AxisGridLine()
                    }
                }
            }
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
                Text("Range")
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
                } label: {
                    Button("\(timeManager.timePeriod.rawValue.capitalized)") {}
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
            }
            
            Menu {
                Button("Move to Today") {
                    timeManager.resetToCurrentPeriod()
                    recalculateChartDataPoints()
                    populateTransactionLists()
                }
                Button("Pick Custom Date Range") {
                    activeSheet = .customDateRange
                }
            } label: {
                Button(action: {}) {
                    Image(systemName: "calendar")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .tint(.primary)
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
                TransactionListView(groupedOccurrences: transactionListMinus2 ?? [], activeSheet: $activeSheet, transactionGroupPeriod: timeManager.timePeriod)
                    .id(-2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListMinus1 ?? [], activeSheet: $activeSheet, transactionGroupPeriod: timeManager.timePeriod)
                    .id(-1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListToday ?? [], activeSheet: $activeSheet, transactionGroupPeriod: timeManager.timePeriod)
                    .id(0)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus1 ?? [], activeSheet: $activeSheet, transactionGroupPeriod: timeManager.timePeriod)
                    .id(1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                    }
                TransactionListView(groupedOccurrences: transactionListPlus2 ?? [], activeSheet: $activeSheet, transactionGroupPeriod: timeManager.timePeriod)
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
                populateTransactionLists()
                recalculateChartDataPoints()
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
            return "weeks \(timeManager.startDate.formatted(.dateTime.week())) and \(timeManager.endDate.formatted(.dateTime.week()))"
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
            $0.date >= timeManager.startDate && $0.date <= timeManager.endDate
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
    
    
    
    
    
    
    // MARK: - Helper Function
    
    
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
    
    
    func populateTransactionLists() {
        
        transactionListMinus2 = groupedOccurrences(startDate: timeManager.previousPeriod2.start, endDate: timeManager.previousPeriod2.end)
        transactionListMinus1 = groupedOccurrences(startDate: timeManager.previousPeriod1.start, endDate: timeManager.previousPeriod1.end)
        transactionListToday = groupedOccurrences(startDate: timeManager.startDate, endDate: timeManager.endDate)
        transactionListPlus1 = groupedOccurrences(startDate: timeManager.nextPeriod1.start, endDate: timeManager.nextPeriod1.end)
        transactionListPlus2 = groupedOccurrences(startDate: timeManager.nextPeriod2.start, endDate: timeManager.nextPeriod2.end)
    }
    
    
    func groupedOccurrences(startDate: Date, endDate: Date) -> [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current

        // 4. Filter occurrences that lie within this shifted range
        let visibleOccurrences = allOccurrences.filter {
            $0.date >= startDate && $0.date <= endDate
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

enum OccurrenceType {
    case transaction(Transaction)
    case reset(BalanceReset)
}

extension ProcessInfo {
    var isRunningInXcodePreview: Bool {
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


#Preview {
    MainView()
}

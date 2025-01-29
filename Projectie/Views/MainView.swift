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
    @State private var selectedBalance: Double? = nil
    @State private var selectedDate: Date? = nil
    @State private var selectedTransaction: Transaction?
    
    @State private var isInteracting: Bool = false
    
    @State private var currentStartDate: Date = Date()
    
    @State private var dragLocation: CGPoint = .zero

    @State private var horizontalOffset: CGFloat = 0
    
    @State private var activeSheet: ActiveSheet?
    
    
    
    
    // MARK: - Main View
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                dynamicTitle
                
                chart
                
                chartControlls
                
                TabView {
                    transactionList
                    goalList
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .ignoresSafeArea(edges: .bottom)
                
            }
            .onAppear {
                updateCurrentStartDate()
            }
            .onChange(of: selectedTimeFrame) { _, newValue in
                updateCurrentStartDate()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { activeSheet = .addTransaction }) {
                            Label("Add transaction", systemImage: "creditcard")
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
                            Label("Reset Balance", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
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
                    Text("End of \(endOfNoun): $\(endOfRangeBalance, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            } else {
                if let selectedDate = selectedDate,
                   let selectedBalance = selectedBalance {
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
    
    // MARK: - Chart
    private var chart: some View {
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
                                // We are interacting
                                isInteracting = true
                                
                                // Convert drag’s x-position into chart coordinate
                                let origin = geoProxy[proxy.plotFrame!].origin
                                let locationXOnChart = value.location.x - origin.x
                                
                                // Distance from each edge of the *screen*
                                let screenWidth = geoProxy.size.width
                                let distanceToLeft = value.location.x
                                
                                // Update horizontal offset so dynamicTitle follows finger
                                // (Choose whichever makes sense for your design)
                                self.horizontalOffset = distanceToLeft - (screenWidth / 2)
                                
                                // Attempt to fetch the date at this x-position
                                if let date: Date = proxy.value(atX: locationXOnChart) {
                                    // Find the closest data point in filteredChartData
                                    if let closest = filteredChartData.min(by: {
                                        abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                    }) {
                                        // Update selected date & balance
                                        self.selectedDate = closest.date
                                        self.selectedBalance = closest.balance
                                    }
                                }
                            }
                            .onEnded { _ in
                                // Once drag ends, revert to the default titles
                                isInteracting = false
                                
                                // Optionally reset offset, or keep it where it ended
                                // self.horizontalOffset = 0
                            }
                    )
            }
        })
    }
    
    
    // MARK: - Chart Controlls
    private var chartControlls: some View {
        
        HStack {
            HStack(spacing: 6) {
                Text("Show")
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
            

            HStack(spacing: 6) {
                Text("Chart")
                Menu {
                    Button(action: {selectedChartStyle = .line} ) {
                        Label("Line", systemImage: "chart.xyaxis.line")
                    }
                    Button(action: {selectedChartStyle = .bar} ) {
                        Label("Bar", systemImage: "chart.bar.xaxis")
                    }
                } label: {
                    Button(action: { }) {
                        Text(selectedChartStyle.rawValue.capitalized)
                            .lineLimit(1)
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }

            }
            
            
            Spacer()
            
            // Previous
            Button(action: {
                changeDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
            .tint(.primary)
            
            // Next
            Button(action: {
                changeDate(by: 1)
            }) {
                Image(systemName: "chevron.right")
                    .tint(.primary)
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
            .tint(.primary)
        }
        .padding(.horizontal)
    }
    
    
    // MARK: - Transaction List
    private var transactionList: some View {
        List {
            ForEach(visibleGroupedOccurrences, id: \.key) { (date, occurrences) in
                Section(header: Text(date, style: .date)) {
                    transactionListDayOrganiser(occurenceList: occurrences, onTransactionSelected: { transaction in
                        activeSheet = .manageTransaction(transaction, date)
                    })
                }
            }
        }
        .safeAreaPadding(.bottom, 40)
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
    
    
    
    /// Only the occurrences (transactions + resets) whose date is visible in the current chart range
    private var visibleGroupedOccurrences: [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current

        // 1) Filter all occurrences to just the date range
        let visibleOccurrences = allOccurrences.filter {
            $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame
        }
        
        // 2) Group them by day
        let grouped = Dictionary(grouping: visibleOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }
        
        // 3) Sort by day
        return grouped
            .sorted { $0.key < $1.key }
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
    
    
    private var filteredChartData: [(date: Date, balance: Double)] {
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
        
        return dataPoints
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

struct transactionListDayOrganiser: View {
    
    var occurenceList: [TransactionOccurrence]
    
    var onTransactionSelected: (Transaction) -> Void = { _ in }
    
    var body: some View {
        
        ForEach(occurenceList) { occ in
            
            switch occ.type {
            case .transaction(let txn):
                TransactionListElement(
                    transaction: txn,
                    overrideDate: occ.date
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    onTransactionSelected(occ.transaction!)
                }
            case .reset(let rst):
                BalanceResetListElement(reset: rst)
            }
            
        }
        
    }
}

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

enum OccurrenceType {
    case transaction(Transaction)
    case reset(BalanceReset)
}


#Preview {
    MainView()
}

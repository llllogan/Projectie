//
//  MainProjectionView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI
import Charts
import SwiftData

struct MainView: View {
    @AppStorage("openingBalance") private var openingBalance = 0.0
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query(sort: \BalanceReset.date, order: .reverse) private var allBalanceResets: [BalanceReset]
    
    @State private var showingAddTransactionSheet = false
    @State private var showResetBalanceSheet: Bool = false
    
    @State private var selectedChartStyle: ChartViewStyle = .line
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var currentStartDate: Date = Date()
    
    @State private var isInteracting: Bool = false
    @State private var selectedDate: Date? = nil
    @State private var selectedBalance: Double? = nil
    
    @State private var dragLocation: CGPoint = .zero
    
    @State private var horizontalOffset: CGFloat = 0
    
    
    
    
    // MARK: - Main View
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                dynamicTitle
                
                chart
                
                chartControlls
                
                transactionList
                
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
                        Button(action: {showingAddTransactionSheet = true} ) {
                            Label("Add transaction", systemImage: "creditcard")
                        }
                        Button(action: {showingAddTransactionSheet = true} ) {
                            Label("Add goal", systemImage: "trophy")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
//                            .tint(.primary.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {showResetBalanceSheet = true} ) {
                            Label("Reset Balance", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .tint(.primary)
                    }
                }

            }
            .sheet(isPresented: $showingAddTransactionSheet) {
                AddTransactionSheet()
            }
            .sheet(isPresented: $showResetBalanceSheet) {
                ResetBalanceSheet()
            }
        }
    }
    
    
    
    // MARK: - Child Views
    
    
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
        .frame(height: 200)
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
    
    
    
    
    
    
    
    // MARK: - Computed Properties
    
    
    private var transactionList: some View {
        List {
            ForEach(groupedOccurrences, id: \.key) { (date, occurrences) in
                Section(header: Text(date, style: .date)) {
                    ForEach(occurrences) { occ in
                        TransactionListElement(
                            transaction: occ.transaction,
                            overrideDate: occ.date // so we can see the exact date
                        )
                    }
                }
            }
        }
    }
    
    
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
        // If you only want resets up to "today", you can also
        // filter allResets by `.date <= Date()`
        allBalanceResets.first
    }
    
    
    private var allOccurrences: [TransactionOccurrence] {
        transactions.flatMap { txn in
            if txn.isRecurring {
                // Expand recurring transactions
                return txn.recurrenceDates.map { d in
                    TransactionOccurrence(transaction: txn, date: d)
                }
            } else {
                // Single occurrence
                return [TransactionOccurrence(transaction: txn, date: txn.date)]
            }
        }
    }
    
    private var groupedOccurrences: [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }
        return grouped.sorted { $0.key > $1.key }
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
            .reduce(0) { $0 + $1.amount }
        
        return baseline + sumAfterReset
    }
    
    
    private var filteredChartData: [(date: Date, balance: Double)] {
        let calendar = Calendar.current
        
        // 1. Sort all transactions and resets in ascending order
        let sortedTransactions = allOccurrences.sorted { $0.date < $1.date }
        let sortedResets = allBalanceResets.sorted { $0.date < $1.date }
        
        // 2. Find the latest reset before the currentStartDate
        let latestResetBeforeStart = sortedResets.last(where: { $0.date <= currentStartDate })
        
        // 3. Initialize running balance and last reset date
        var runningBalance: Double
        var lastResetDate: Date
        
        if let reset = latestResetBeforeStart {
            runningBalance = reset.balanceAtReset
            lastResetDate = reset.date
        } else {
            runningBalance = openingBalance
            lastResetDate = Date.distantPast
        }
        
        // 4. Apply transactions between the last reset and the start date
        let transactionsBeforeStart = sortedTransactions.filter { $0.date > lastResetDate && $0.date < currentStartDate }
        for txn in transactionsBeforeStart {
            runningBalance += txn.amount
        }
        
        // 5. Filter resets and transactions within the timeframe
        let resetsWithinTimeFrame = sortedResets.filter { $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame }
        let transactionsWithinTimeFrame = sortedTransactions.filter { $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame }
        
        // 6. Group transactions and resets by day
        let transactionsByDay = Dictionary(
            grouping: transactionsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }
        
        let resetsByDay = Dictionary(
            grouping: resetsWithinTimeFrame
        ) { calendar.startOfDay(for: $0.date) }
        
        // 7. Iterate through each day in the timeframe
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
            
            // Apply any transactions on this day
            if let todaysTransactions = transactionsByDay[currentDate] {
                for txn in todaysTransactions {
                    runningBalance += txn.amount
                }
            }
            
            // Record the balance for this day
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
    
    private func sumOfAllTransactionsUpTo(_ date: Date) -> Double {
        allOccurrences
            .filter { $0.date <= date }
            .reduce(0) { $0 + $1.amount }
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

struct TransactionOccurrence: Identifiable {
    let transaction: Transaction
    let date: Date
    
    // Combine transaction ID & date to ensure uniqueness
    var id: String { "\(transaction.id)-\(date.timeIntervalSince1970)" }
    
    var amount: Double {
        transaction.amount
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


#Preview {
    MainView()
}

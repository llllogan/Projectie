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
    
    @State private var showingAddTransactionSheet = false
    @State private var showResetBalanceSheet: Bool = false
    
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
            // NavigationBar / Toolbar
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
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {showResetBalanceSheet = true} ) {
                            Label("Reset Balance", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
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
        
        var endOfNoun: String {
            switch selectedTimeFrame {
            case .week:
                return "week \(currentStartDate.formatted(.dateTime.week()))"
            case .month:
                return currentStartDate.formatted(.dateTime.month(.wide))
            case .year:
                return currentStartDate.formatted(.dateTime.year())
            }
        }
        
        return VStack {
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
        let chartMin = min(minBalance, 0)
        let chartMax = maxBalance
        
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
            // Picker for Time Frame
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { frame in
                    Text(frame.rawValue.capitalized).tag(frame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            // Previous
            Button(action: {
                changeDate(by: -1)
            }) {
                Image(systemName: "chevron.left")
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.borderedProminent)
            
            // Next
            Button(action: {
                changeDate(by: 1)
            }) {
                Image(systemName: "chevron.right")
            }
            .buttonBorderShape(.circle)
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }
    
    
    var transactionList: some View {
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
    
    
    
    
    
    
    
    // MARK: - Computed Properties
    
    private var allOccurrences: [TransactionOccurrence] {
        transactions.flatMap { txn in
            if txn.isRecurring {
                // For recurring transactions, expand each date in recurrenceDates
                return txn.recurrenceDates.map { d in
                    TransactionOccurrence(transaction: txn, date: d)
                }
            } else {
                // Not recurring => single occurrence
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
        // We'll consider all occurrences up to "today"
        let today = Date()
        // Filter occurrences up to "today"
        let relevant = allOccurrences.filter { $0.date <= today }
        // Sum up amounts
        let sum = relevant.reduce(0) { $0 + $1.amount }
        return openingBalance + sum
    }
    
    private var filteredChartData: [(date: Date, balance: Double)] {
        // Sort all occurrences by date
        let sortedOccurrences = allOccurrences.sorted { $0.date < $1.date }
        
        // 1) Compute how much the balance was before the currentStartDate
        let balanceBeforeStartDate = sortedOccurrences
            .filter { $0.date < currentStartDate }
            .reduce(openingBalance) { $0 + $1.amount }
        
        // 2) Group only the transactions that fall between startDate and endDate
        let occurrencesByDay = Dictionary(
            grouping: sortedOccurrences.filter {
                $0.date >= currentStartDate && $0.date <= endDateForCurrentTimeFrame
            }
        ) {
            Calendar.current.startOfDay(for: $0.date)
        }
        
        // 3) Iterate day-by-day, starting from currentStartDate up to endDateForCurrentTimeFrame
        var dataPoints: [(date: Date, balance: Double)] = []
        var runningBalance = balanceBeforeStartDate
        
        var currentDate = currentStartDate
        let endDate = endDateForCurrentTimeFrame
        
        while currentDate <= endDate {
            // If there are any transactions on this day, add them to the running balance
            if let todaysOccurrences = occurrencesByDay[currentDate] {
                for occ in todaysOccurrences {
                    runningBalance += occ.amount
                }
            }
            // Record (day, runningBalance) in the data points
            dataPoints.append((date: currentDate, balance: runningBalance))
            
            // Move currentDate forward by one day
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
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


#Preview {
    MainView()
}

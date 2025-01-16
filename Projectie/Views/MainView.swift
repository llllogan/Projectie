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
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var currentStartDate: Date = Date()
    
    
    var body: some View {
        NavigationView {
            VStack {
                
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTransactionSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("$\(currentBalance, format: .number.precision(.fractionLength(2)))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
            .sheet(isPresented: $showingAddTransactionSheet) {
                AddTransactionSheet()
            }
        }
    }
    
    private var chart: some View {
        Chart {
            ForEach(filteredChartData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Balance", dataPoint.balance)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
        .padding()
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
    
    // 1) Flatten transactions into a list of all "occurrences"
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
    
    // 2) Group occurrences by day for the List
    var groupedOccurrences: [(key: Date, value: [TransactionOccurrence])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: allOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    // 3) Current total balance
    private var currentBalance: Double {
        // We'll consider all occurrences up to "today"
        let today = Date()
        // Filter occurrences up to "today"
        let relevant = allOccurrences.filter { $0.date <= today }
        // Sum up amounts
        let sum = relevant.reduce(0) { $0 + $1.amount }
        return openingBalance + sum
    }
    
    // 4) Chart data using all occurrences
    private var filteredChartData: [(date: Date, balance: Double)] {
        var dataPoints: [(date: Date, balance: Double)] = []
        var runningBalance = openingBalance
        
        let calendar = Calendar.current
        
        // Sort occurrences by date
        let sortedOccurrences = allOccurrences.sorted { $0.date < $1.date }
        
        // Group by day
        let occurrencesByDay = Dictionary(grouping: sortedOccurrences) { occ in
            calendar.startOfDay(for: occ.date)
        }
        
        // Build a date range from currentStartDate to endDateForCurrentTimeFrame
        let startDate = currentStartDate
        let endDate = endDateForCurrentTimeFrame
        
        // Iterate day by day
        var currentDate = startDate
        while currentDate <= endDate {
            if let todaysOccurrences = occurrencesByDay[currentDate] {
                for occ in todaysOccurrences {
                    runningBalance += occ.amount
                }
            }
            dataPoints.append((date: currentDate, balance: runningBalance))
            
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        return dataPoints
    }
    
    private var endDateForCurrentTimeFrame: Date {
        switch selectedTimeFrame {
        case .week:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentStartDate) ?? currentStartDate
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: currentStartDate) ?? currentStartDate
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
}


#Preview {
    MainView()
}

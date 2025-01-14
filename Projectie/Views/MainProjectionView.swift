//
//  MainProjectionView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import SwiftUI
import Charts
import SwiftData

struct MainProjectionView: View {
    @AppStorage("openingBalance") private var openingBalance = 0.0
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var groupedTransactions: [(key: Date, value: [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { trxn -> Date in
            return calendar.startOfDay(for: trxn.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    @State private var showingAddTransactionSheet = false
    
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var currentStartDate: Date = Date()
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                // CHART
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
                
                HStack {
                    // Picker for Time Frame Selection
                    Picker("Time Frame", selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { frame in
                            Text(frame.rawValue.capitalized).tag(frame)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Spacer()
                    
                    // Previous Button
                    Button(action: {
                        changeDate(by: -1)
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    // Next Button
                    Button(action: {
                        changeDate(by: 1)
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                }
                
                // LIST OF TRANSACTIONS
                // Display each transaction in a row
                List {
                    ForEach(groupedTransactions, id: \.key) { (date, transactionGroup) in
                        Section(header: Text(date, style: .date)) {
                            ForEach(transactionGroup) { transaction in
                                TransactionListElement(transaction: transaction)
                            }
                        }
                    }
                }
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
            // SHEET FOR ADDING A NEW TRANSACTION
            .sheet(isPresented: $showingAddTransactionSheet) {
                AddTransactionSheet()
            }
        }
    }
    
    
    // MARK: - Computed Properties
    
    private var currentBalance: Double {
        openingBalance + transactions.reduce(0) { $0 + $1.amount }
    }
    
    private var actualChartData: [(date: Date, balance: Double)] {
        var dataPoints: [(Date, Double)] = []
        var runningBalance = openingBalance
        
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        for txn in sortedTransactions {
            runningBalance += txn.amount
            dataPoints.append((txn.date, runningBalance))
        }
        return dataPoints
    }
    
    private var filteredChartData: [(date: Date, balance: Double)] {
        actualChartData.filter { dataPoint in
            dataPoint.date >= currentStartDate &&
            dataPoint.date < endDateForCurrentTimeFrame
        }
    }
    
    private var filteredTransactions: [Transaction] {
        transactions.filter { txn in
            txn.date >= currentStartDate &&
            txn.date < endDateForCurrentTimeFrame
        }
    }
    
    private var endDateForCurrentTimeFrame: Date {
        switch selectedTimeFrame {
        case .week:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentStartDate) ?? currentStartDate
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: currentStartDate) ?? currentStartDate
        }
    }
    
    
    // MARK: - Methods
    
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
    
    // Optional: Reset to current period when time frame changes
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

enum TimeFrame: String, CaseIterable {
    case week
    case month
}

#Preview {
    MainProjectionView()
}

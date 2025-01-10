//
//  ContentView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import SwiftUI
import Charts
import SwiftData

struct ContentView: View {
    // MARK: SwiftData Context
    @Environment(\.modelContext) private var modelContext
    
    // MARK: Opening balance (for example, stored in UserDefaults via @AppStorage)
    @AppStorage("openingBalance") private var openingBalance = 1000.0

    // MARK: Query all transactions
    @Query(sort: \Transaction.date, order: .forward) var transactions: [Transaction]

    // MARK: State for new transaction input
    @State private var transactionNote: String = ""
    @State private var transactionAmount: String = ""  // store as text; convert to Double on save

    var body: some View {
        NavigationView {
            VStack {
                // Chart of balance over time, plus a short projection
                Chart {
                    // Actual data: plot from earliest transaction date up to now
                    ForEach(actualChartData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(.blue)
                    }
                    
                    // Projection data: simple placeholder logic
                    // If you want a more robust projection, add your own logic here
                    ForEach(projectionChartData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Projected Balance", dataPoint.balance)
                        )
                        .foregroundStyle(.gray)
                        .interpolationMethod(.catmullRom)
                        .opacity(0.7)
                    }
                }
                .frame(height: 200)
                .padding()
                
                // Current Balance
                Text("Current Balance: \(currentBalance, format: .number.precision(.fractionLength(2)))")
                    .font(.headline)
                    .padding(.bottom)

                // Form to add a credit/debit
                Form {
                    Section(header: Text("Add Transaction")) {
                        TextField("Note", text: $transactionNote)
                        TextField("Amount (positive or negative)", text: $transactionAmount)
                            .keyboardType(.decimalPad)
                        Button("Add Transaction") {
                            addTransaction()
                        }
                    }
                }
                .navigationTitle("Savings Tracker")
            }
        }
    }

    // MARK: - Computed Properties

    /// Current total balance based on openingBalance + sum of all transaction amounts
    private var currentBalance: Double {
        openingBalance + transactions.reduce(0) { $0 + $1.amount }
    }

    /// Data for the actual transactions up to the current date (for chart)
    private var actualChartData: [(date: Date, balance: Double)] {
        var dataPoints: [(Date, Double)] = []
        var runningBalance = openingBalance

        // Sort transactions by date just to be sure
        let sortedTransactions = transactions.sorted { $0.date < $1.date }
        for txn in sortedTransactions {
            runningBalance += txn.amount
            dataPoints.append((txn.date, runningBalance))
        }
        return dataPoints
    }
    
    /// Projection data for the future, e.g., next 5 days, weeks, or months
    /// This is just a placeholder; replace with your own logic
    private var projectionChartData: [(date: Date, balance: Double)] {
        guard let lastEntry = actualChartData.last else { return [] }

        // Example: project for next 5 days with a simplified approach
        // We'll assume an average daily change based on the last 7 days
        // Or just assume a constant for demonstration
        let daysToProject = 5
        let dailyChange = calculateAverageDailyChange()

        var projectedData: [(Date, Double)] = []
        var currentDate = lastEntry.date
        var runningBalance = lastEntry.balance

        for _ in 1...daysToProject {
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            runningBalance += dailyChange
            projectedData.append((currentDate, runningBalance))
        }
        return projectedData
    }

    // MARK: - Methods

    /// Calculate average daily change over the last 7 days (simple example)
    private func calculateAverageDailyChange() -> Double {
        // You can implement actual logic here
        // For now, let's just use a small random value for demo
        return Double.random(in: -10...10)
    }

    private func addTransaction() {
        guard let amount = Double(transactionAmount) else {
            // You might show an alert here
            return
        }
        
        let newTxn = Transaction(amount: amount, date: Date(), note: transactionNote)
        modelContext.insert(newTxn)
        
        // Clear input fields
        transactionNote = ""
        transactionAmount = ""
    }
}

#Preview {
    ContentView()
}

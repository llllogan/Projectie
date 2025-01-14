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
    // MARK: Opening balance (for example, stored in UserDefaults via @AppStorage)
    @AppStorage("openingBalance") private var openingBalance = 0.0
    
    @Environment(\.modelContext) private var context

    // MARK: Query all transactions
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    // MARK: State for Add Transaction sheet
    @State private var showingAddTransactionSheet = false
    

    var body: some View {
        NavigationView {
            VStack {
                // CHART
                Chart {
                    // Actual data
                    ForEach(actualChartData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(.blue)
                    }
                    
                    // Projection data
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

                // CURRENT BALANCE
                Text("Current Balance: \(currentBalance, format: .number.precision(.fractionLength(2)))")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("Number of transactions: \(transactions.count)")
                
                // LIST OF TRANSACTIONS
                // Display each transaction in a row
                List(transactions) { transaction in
                    TransactionListElement(transaction: transaction)
                }
            }
            // NavigationBar / Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTransactionSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
    
    private var projectionChartData: [(date: Date, balance: Double)] {
        guard let lastEntry = actualChartData.last else { return [] }
        
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

    private func calculateAverageDailyChange() -> Double {
        Double.random(in: -10...10)
    }
}


#Preview {
    ContentView()
}

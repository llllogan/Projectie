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
    @AppStorage("hasSetInitialBalance") private var hasSetInitialBalance: Bool = false
    @AppStorage("sqaureLines") private var squareLines: Bool = false
    @AppStorage("currentAppIcon") private var appIcon: String = "Orange"
    
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var chartDataManager: ChartManager
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var financialEventManager: FinancialEventManager
    @EnvironmentObject private var controlManager: ControlManager
    @EnvironmentObject private var transactionManager: TransactionManager
    @EnvironmentObject private var balanceResetManager: BalanceResetManager
    @EnvironmentObject private var goalManager: GoalManager
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    
    @State private var showAddInitialBalanceSheet = false
    @State private var activeSheet: ActiveSheet?
    
    // MARK: - Main View
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                DynamicTitleParent()
                
                
                if (controlManager.selectedChartView == .line) {
                    LineGraphParent()
                        .frame(height: 200)
                } else {
                    BarGraphParent()
                        .frame(height: 200)
                }
                
                
                CentreControlParent()
                    .padding(.horizontal)
                
                
                if (controlManager.selectedBottomView == .goals) {
                    GoalListParent()
                } else {
                    TransactionListParent()
                }
                
            }
            .onAppear {
                
                accountManager.setContext(context)
                
                timeManager.calculateDates()
            
                if (!hasSetInitialBalance && !ProcessInfo.processInfo.isRunningInXcodePreview) {
                    showAddInitialBalanceSheet = true
                }
            }
            .onChange(of: timeManager.timePeriod) { _, newValue in
                financialEventManager.doUpdates()
                chartDataManager.recalculateChartDataPoints()
            }
            .onChange(of: themeManager.selectedTheme) { _, newTheme in
                if newTheme == .carrotCustom && !themeManager.hasSetCustomColour {
                    activeSheet = .pickColour
                }
            }
            .onChange(of: appIcon) { _, newValue in
                if (newValue == "Orange") {
                    UIApplication.shared.setAlternateIconName(nil)
                } else {
                    UIApplication.shared.setAlternateIconName(newValue)
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
                    case .addGoal:
                        AddGoalSheet()
                            .presentationDragIndicator(.visible)
                    case .pickColour:
                        FullscreenColorPickerView()
                            .presentationDragIndicator(.visible)
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
                            .foregroundColor(themeManager.accentColor)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Graph Style", selection: $controlManager.selectedChartView) {
                            Label("Line", systemImage: "chart.xyaxis.line")
                                .tag(ChartViewChoice.line)
                            Label("Bar", systemImage: "chart.bar.xaxis")
                                .tag(ChartViewChoice.bar)
                        }
                        Button(action: {
                            squareLines.toggle()
                        }) {
                            Label("Line Interpolation Style", systemImage: "arrow.trianglehead.2.clockwise")
                        }
                        Divider()
                        Menu {
                            Picker("Colour Scheme", selection: $themeManager.selectedTheme) {
                                Text("Dutch")
                                    .tag(AccentTheme.carrotOrrange)
                                Text("Proto-European")
                                    .tag(AccentTheme.carrotPurple)
                                Text("GMO")
                                    .tag(AccentTheme.carrotCustom)
                            }
                            Button(action: {
                                activeSheet = .pickColour
                            }) {
                                Label("Pick Custom Colour", systemImage: "swatchpalette")
                            }
                        } label: {
                            Text("Colour Scheme")
                                .tint(.primary)
                        }
                        Menu {
                            Picker("App Icon", selection: $appIcon) {
                                let customIcons: [String] = ["Orange", "Purple", "OG"]
                                ForEach(customIcons,id: \.self) { icon in
                                    Text(icon)
                                        .tag(icon)
                                }
                            }
                        } label: {
                            Text("App Icon")
                                .tint(.primary)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .tint(.primary)
                    }
                }
            }
        }
    }
}


// MARK: - Supporting Types

enum ActiveSheet: Identifiable {
    case addTransaction
    case resetBalance
    case addGoal
    case pickColour
    
    var id: Int {
        UUID().hashValue
    }
}

extension ProcessInfo {
    var isRunningInXcodePreview: Bool {
        return environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}


#Preview {
    MainView()
        /// Manager for User Accounts
        .environmentObject(AccountManager.shared)

        /// Managers for Financial Events
        .environmentObject(FinancialEventManager.shared)
        .environmentObject(TransactionManager.shared)
        .environmentObject(GoalManager.shared)
        .environmentObject(BalanceResetManager.shared)

        /// Other Mics Managers
        .environmentObject(TimeManager.shared)
        .environmentObject(ControlManager.shared)
        .environmentObject(ChartManager.shared)
        .environmentObject(ThemeManager.shared)
}

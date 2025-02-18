//
//  ProjectieApp.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 10/1/2025.
//

import SwiftUI
import SwiftData

@main
struct ProjectieApp: App {
    
    var container: ModelContainer = {
        let schema = Schema([Transaction.self, BalanceReset.self, Goal.self, Account.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, migrationPlan: CarrotMigrationPlan.self)
        } catch {
            fatalError("Failed to create model container wamp wamp: \(error)")
        }
    }()
    
    init() { }
    

    var body: some Scene {
        WindowGroup {
            MainView()
                /// Swift Data model container
                .modelContainer(container)
            
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
    }
}

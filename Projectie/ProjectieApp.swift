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
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create model container wamp wamp: \(error)")
        }
    }()
    
    init() {
        AccountManager.shared.setContext(container.mainContext)
        TransactionManager.shared.setContext(container.mainContext)
    }
    

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(container)
                .environmentObject(AccountManager.shared)
                .environmentObject(TransactionManager.shared)
                .environmentObject(TimeManager.shared)
        }
    }
}

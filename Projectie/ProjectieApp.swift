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

    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Transaction.self, BalanceReset.self, Goal.self])
        }
    }
}

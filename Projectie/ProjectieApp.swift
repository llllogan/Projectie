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
            ContentView()
                .modelContainer(for: Transaction.self)
        }
    }
}

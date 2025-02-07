//
//  GoalManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import Foundation
import SwiftData
import Combine

final class GoalManager:ObservableObject {
    
    static let shared = GoalManager()
    
    private var context: ModelContext?
    
    private init() { }
    
    var goals: [Goal] {
        guard let context = context else {
            print("ModelContext has not been set for GoalManager.")
            return []
        }
        
        // Ensure we have a selected account.
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            return []
        }
        
        let accountID: UUID = selectedAccount.id
        
        // Build a predicate that filters transactions for the selected account.
        let predicate = #Predicate<Goal> { goal in
            goal.account.id == accountID
        }
        
        let fetchDescriptor = FetchDescriptor<Goal>(predicate: predicate)
        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            print("Error fetching goals: \(error)")
            return []
        }
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    
}

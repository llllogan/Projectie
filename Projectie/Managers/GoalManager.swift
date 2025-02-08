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
    
    @Published var goals: [Goal] = []
    
    func setGoals(_ goals: [Goal]) {
        
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            self.goals = []
            return
        }
        
        let accountID: UUID = selectedAccount.id
        
        let relevantGoals: [Goal] = goals.filter { $0.account.id == accountID }
        
        self.goals = relevantGoals
    }
}

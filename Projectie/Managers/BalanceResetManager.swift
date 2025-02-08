//
//  BalanceResetManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import Foundation
import SwiftData
import Combine

final class BalanceResetManager: ObservableObject {
    
    static let shared = BalanceResetManager()
    
    private var context: ModelContext?
    
    private init() { }
    
    @Published var resets: [BalanceReset] = []
    
    func setResets(_ resets: [BalanceReset]) {
        
        guard let selectedAccount = AccountManager.shared.selectedAccount else {
            print("No account selected.")
            self.resets = []
            return
        }
        
        let accountID: UUID = selectedAccount.id
        
        let relevantResets: [BalanceReset] = resets.filter { $0.account.id == accountID }
        
        self.resets = relevantResets
    }
}

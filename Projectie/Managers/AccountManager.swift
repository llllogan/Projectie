//
//  AccountManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import SwiftData
import Combine

final class AccountManager: ObservableObject {

    static let shared = AccountManager()
    
    private var context: ModelContext?
    
    @Published var selectedAccount: Account?
    
    private init() { }
    
    func setContext(_ context: ModelContext) {
        self.context = context
        
        if accounts.isEmpty {
            addDefaultAccounts()
        }
        
        if selectedAccount == nil {
            selectedAccount = accounts.first(where: { $0.type == .saving })
        }
    }
    
    var accounts: [Account] {
        guard let context = context else {
            print("No model context set for AccountManager")
            return []
        }
        
        let fetchDescriptor = FetchDescriptor<Account>()
        do {
            return try context.fetch(fetchDescriptor)
        } catch {
            print("Error fetching accounts: \(error)")
            return []
        }
    }
    
    /// Example function to add default accounts.
    private func addDefaultAccounts() {
        guard let context = context else { return }
        let savingsAccount = Account(name: "Savings",
                                     type: .saving,
                                     number: "8008135",
                                     incurresInterest: false)
        
        context.insert(savingsAccount)
        try? context.save()
    }
}

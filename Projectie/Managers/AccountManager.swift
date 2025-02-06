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
    /// A global shared instance.
    static let shared = AccountManager()
    
    /// Holds the SwiftData model context.
    private var context: ModelContext?
    
    /// The currently selected account.
    @Published var selectedAccount: Account?
    
    /// Private initializer to enforce singleton usage.
    private init() { }
    
    /// Sets the model context. Call this as soon as the context becomes available,
    /// for example in your App or Scene delegate.
    func setContext(_ context: ModelContext) {
        self.context = context
        
        // Optionally add default accounts if needed.
        if accounts.isEmpty {
            addDefaultAccounts()
        }
        
        // Set the selected account if one isn’t already chosen.
        if selectedAccount == nil {
            selectedAccount = accounts.first(where: { $0.type == .saving })
        }
    }
    
    /// Fetches all accounts using SwiftData.
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

//
//  AccountManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import Foundation
import Combine
import SwiftData
import SwiftUI

class AccountManager: ObservableObject {
    
    @Environment(\.modelContext) private var context
    
    @Query
    @Published
    var accounts: [Account]
    
    @Published var selectedAccount: Account?
    
    private var appShowsAccounts = false
    
    static let shared = AccountManager()
    
    private init() {
        
        if (accounts.isEmpty && !appShowsAccounts) {
            addDefaultAccounts()
        }
        
        if (!appShowsAccounts) {
            selectedAccount = accounts.first(where: { $0.type == .saving })
        }
        
    }
    
    private func addDefaultAccounts() {
        let savingsAccount = Account(name: "Savings", type: .saving, number: "8008135", incurresInterest: false)
//        let spendingAccount = Account(name: "Spending", type: .saving, number: "8008135", incurresInterest: false)
        
        context.insert(savingsAccount)
//        context.insert(spendingAccount)
        
        try? context.save()
    }
}

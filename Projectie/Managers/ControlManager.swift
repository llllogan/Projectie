//
//  ControlManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 7/2/2025.
//

import Foundation
import SwiftData
import Combine

final class ControlManager: ObservableObject {
    
    static let shared = ControlManager()
    
    private init() { }
    
    @Published var selectedBottomView: BottomViewChoice = .transactions
}



enum BottomViewChoice: String, CaseIterable {
    case transactions
    case goals
}

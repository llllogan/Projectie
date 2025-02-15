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
    @Published var selectedChartView: ChartViewChoice = .line
    
    @Published var screenWidth: CGFloat = 0
    
    @Published var maxAllowedLeftOffset: CGFloat = 0
    @Published var maxAllowedRightOffset: CGFloat = 0
    
    func calculateMaxOffsets(_ titleWidth: CGFloat) {
        let halfScreenWidth = screenWidth / 2
        let halfTitleWidth = titleWidth / 2
        
        maxAllowedRightOffset = halfScreenWidth - halfTitleWidth
        maxAllowedLeftOffset = -maxAllowedRightOffset
    }
}


enum BottomViewChoice: String, CaseIterable {
    case transactions
    case goals
}

enum ChartViewChoice: String, CaseIterable {
    case line
    case bar
}

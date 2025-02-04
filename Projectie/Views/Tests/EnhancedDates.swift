//
//  EnhancedDates.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 4/2/2025.
//

import SwiftUI
import Foundation

struct EnhancedDates: View {
    
    @ObservedObject private var timeManager = TimeManager.shared
        
    init() {
        timeManager.timePeriod = .fortnight
    }
    
    
    var body: some View {
        VStack {
            Text("Start Date: \(timeManager.startDate, format: .dateTime.day().month().year())")
            Text("End Date: \(timeManager.endDate, format: .dateTime.day().month().year())")
            
            
            Picker("Period", selection: $timeManager.timePeriod) {
                Text("Week").tag(TimePeriod.week)
                Text("Fortnight").tag(TimePeriod.fortnight)
                Text("Month").tag(TimePeriod.month)
                Text("Year").tag(TimePeriod.year)
            }
            
            HStack {
                Button(action: {
                    timeManager.shiftPeriod(by: -1)
                }) {
                    Text("Remove One Period")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    timeManager.shiftPeriod(by: 1)
                }) {
                    Text("Add One Period")
                }
                .buttonStyle(.bordered)
            }
            HStack {
                Button(action: {
                    timeManager.shiftPeriod(by: -2)
                }) {
                    Text("Remove Two Period")
                }
                .buttonStyle(.bordered)
                Button(action: {
                    timeManager.shiftPeriod(by: 2)
                }) {
                    Text("Add Two Period")
                }
                .buttonStyle(.bordered)
            }
            
            
        }
    }
}

#Preview {
    EnhancedDates()
}

//
//  ManageGoalSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/2/2025.
//

import SwiftUI
import SwiftData

struct ManageGoalSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @FocusState private var focusedField: Field?
    
    @State private var currentBalance = FinancialEventManager.shared.currentBalance
    @State private var granularity: DisplayedRemainingTimeGranularity = .days
    
    @State var goal: Goal
    
    enum Field {
        case amount
        case title
        case note
        case occurences
        case notes
    }
    
    var body: some View {
        
        let dateReached = goal.earliestDateWhenGoalIsMet()
        
        NavigationView {
            VStack {
                
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Color.yellow)
                    .font(.largeTitle)
                
                Text(goal.title)
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("$\(goal.targetAmount, format: .number.precision(.fractionLength(2)))")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .padding(.bottom, 8)
                
                
                
                HStack(alignment: .top) {

                    VStack (alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(reachByNounText(dateReached))
                        }

                        HStack {
                            Image(systemName: "hourglass")
                            Text(reachInNounText(dateReached))
                        }

                    }
                    .frame(maxWidth: .infinity)

                    VStack (alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "dollarsign.ring")
                            Text("$\(remainingAmount, specifier: "%.2f")")
                        }
                        HStack {
                            Image(systemName: "dollarsign.ring.dashed", variableValue: progress)
                            Text("\(Int(progress * 100))%")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 40)
                
                
                
                Spacer()
                
                Button(action: {
                    context.delete(goal)
                    try? context.save()
                    dismiss()
                }) {
                    Text("Delete Goal")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(Color.red)
                .padding(.bottom)
                
            }
            .padding(.top, 60)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: dismissKeyboard) {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                }
            }
        }
    }
    
    
    var remainingAmount: Double {
        goal.targetAmount - currentBalance < 0 ? 0 : goal.targetAmount - currentBalance
    }

    var progress: Double {
        currentBalance / goal.targetAmount
    }
    
    func reachInNounText(_ dateReached: Date?) -> String {
        
        if let dateReached = dateReached {
            
            let remainingTime = dateReached.timeIntervalSince(Date())
            
            if (remainingTime <= 0) {
                return "Done!"
            } else {
                
                switch granularity {
                case .days:
                    return "\(Int(remainingTime / 86400)) days"
                case .weeks:
                    return "\(Int(remainingTime / 604800)) weeks"
                case .months:
                    return "\(Int(remainingTime / 2629743)) months"
                case .years:
                    return "\(Int(remainingTime / 31536000)) years"
                }
            }
        }
        
        return "-"
    }
    
    func reachByNounText(_ dateReached: Date?) -> String {
        
        if let date = dateReached {
            
            if date == Date() {
                return "Today"
            }
            
            return date.formatted(.dateTime.day().month().year())
        }
        
        return "-"
    }
    
    private func dismissKeyboard() {
        focusedField = nil
    }
}

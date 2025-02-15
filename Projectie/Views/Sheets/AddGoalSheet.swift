//
//  AddGoalSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 28/1/2025.
//

import SwiftUI

struct AddGoalSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject private var accountManager: AccountManager
    @EnvironmentObject private var controlManager: ControlManager
    
    
    @State private var goalAmount: String = ""
    @State private var goalTitle: String = ""
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
                
//                Image(systemName: "trophy.fill")
//                    .font(.largeTitle)
//                    .foregroundStyle(.yellow)
//                Text("Add a Goal")
//                    .font(.title)
//                    .fontWeight(.bold)
                
                HStack {
                    Text("Add Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                }
                .padding(.horizontal)
                
                TextField("Title", text: $goalTitle)
                    .font(.system(size: 20, weight: .medium))
                    .focused($focusedField, equals: .title)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                
                TextField("0.00", text: $goalAmount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .focused($focusedField, equals: .amount)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
                
                
                Button(action: {
                    saveGoal()
                }) {
                    Text("Add Goal")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.yellow)
                .padding(.bottom)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: dismissKeyboard) {
                        Image(systemName: "keyboard.chevron.compact.down.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.whiteInDarkBlackInLight)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func saveGoal() {
        guard let amount = Double(goalAmount) else { return }
        
        guard let account = accountManager.selectedAccount else { return }
        
        let newGoal = Goal(title: goalTitle, targetAmount: amount, account: account)
        context.insert(newGoal)
        try? context.save()
        
        controlManager.selectedBottomView = .goals
        
        dismiss()
    }
    
    enum Field {
        case amount
        case title
        case note
        case occurences
   }
}

#Preview {
    AddGoalSheet()
}

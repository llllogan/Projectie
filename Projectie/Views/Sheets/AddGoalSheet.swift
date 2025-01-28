//
//  AddGoalSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 28/1/2025.
//

import SwiftUI

struct AddGoalSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    @Environment(\.modelContext) private var context
    
    @State private var goalAmount: String = ""
    @State private var goalTitle: String = ""
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .center) {
                
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.yellow)
                Text("Add a Goal")
                    .font(.title)
                    .fontWeight(.bold)
                
                Form {
                    
                    Section {
                        TextField("Title", text: $goalTitle)
                            .font(.system(size: 20, weight: .medium))
                            .focused($focusedField, equals: .title)
                    }
                    
                    Section(header: Text("Amount")) {
                        TextField("0.00", text: $goalAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .focused($focusedField, equals: .amount)
                    }
                }
                .scrollDisabled(true)
                
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
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(goalAmount) else { return }
        
        let newGoal = Goal(title: goalTitle, targetAmount: amount)
        context.insert(newGoal)
        try? context.save()
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

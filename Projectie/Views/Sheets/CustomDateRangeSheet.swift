//
//  CustomDateRangeSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 4/2/2025.
//

import SwiftUI

struct CustomDateRangeSheet: View {
    @State private var startDate: Date?
    @State private var endDate: Date?
    
    @State private var showFullButtonTest: Bool = false
                    
    @State private var dates: Set<DateComponents> = []
    
    @State private var showErrorAlert = false
    
    @FocusState private var focusedField: Field?
    
    @Environment(\.dismiss) private var dismiss
    
    var onReturn: (_ start: Date, _ end: Date) -> Void

    var body: some View {
        VStack(spacing: 20) {
            MultiDatePicker("Dates Available", selection: $dates)
                .datePickerStyle(GraphicalDatePickerStyle())
                .frame(maxHeight: 350)
                .padding(.top)
            
            Button(action: {
                
                guard let start = startDate, let end = endDate else {
                    showErrorAlert = true
                    return
                }
                
                onReturn(start, end)
                dismiss()
            }) {
                if showFullButtonTest {
                    Text("From \(startDate!, format: .dateTime.day().month().year()) to \(endDate!, format: .dateTime.day().month().year())")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    Text("Select Dates")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: dismissKeyboard) {
                    Image(systemName: "keyboard.chevron.compact.down.fill")
                }
            }
        }
        .alert("Selection Issue", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {
                showErrorAlert = false
            }
        } message: {
            Text("Please select a start and end date.")
        }
        .padding()
        .onChange(of: dates) { oldValue, newValue in
            
            var dateArray = Array(newValue)
            
            if dateArray.count == 3 {
                showFullButtonTest = false
                
                startDate = nil
                endDate = nil
                
                let newDatePosition = newValue.subtracting(oldValue)

                dates = newDatePosition
            }
            
            if (dateArray.count == 2) {
                
                dateArray.sort { comp1, comp2 in
                    guard let date1 = Calendar.current.date(from: comp1),
                          let date2 = Calendar.current.date(from: comp2) else {
                        return false
                    }
                    return date1 < date2
                }
                
                if let firstDate = dateArray.first!.date {
                    startDate = firstDate
                }
                
                if let lastDate = dateArray.last!.date {
                    endDate = lastDate
                }
                
                showFullButtonTest = true
            }
        }
    }
    
    enum Field {
        case amount
        case title
        case note
        case occurences
    }
    
    private func dismissKeyboard() {
        focusedField = nil
    }
}

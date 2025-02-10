//
//  CategoryPicker.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 12/1/2025.
//

import SwiftUI

struct CategoryPicker: View {
    /// Hard-coded list of system icon names.
        
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var onSystemNameSelected: (String) -> Void = { _ in }
    
    @Binding var currentSelection: String?

    @Environment(\.presentationMode) private var presentationMode
    
    init(
        onSystemNameSelected: @escaping (String) -> Void = { _ in },
        currentSelection: Binding<String?>? = nil
    ) {
        self.onSystemNameSelected = onSystemNameSelected
        // If a binding is provided, use it; otherwise, default to a constant nil binding
        self._currentSelection = currentSelection ?? .constant(nil)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories) { category in
                    Button {
                        onSystemNameSelected(category.systemName)
                        hapticButtonPress()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                if (currentSelection == category.systemName) {
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 3)
                                        .frame(width: 77, height: 77)
                                        .offset(x: 0, y: 0)
                                    Circle()
                                        .foregroundColor(category.color)
                                        .frame(width: 66, height: 66)

                                } else {
                                    Circle()
                                        .foregroundColor(category.color)
                                        .frame(width: 77, height: 77)
                                }
                                Image(systemName: category.systemName)
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            Text(category.name)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                Button {
                    onSystemNameSelected("__nil_category__")
                    hapticCancel()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .foregroundColor(Color.blue.opacity(0.8))
                                .frame(width: 77, height: 77)
                            Image(systemName: "delete.left.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .imageScale(.large)
                        }
                        Text("Clear")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
    }
}

#Preview {
    // Example usage: print the selected name in the debug console
    CategoryPicker { selectedName in
        print("Parent view received: \(selectedName)")
    }
}

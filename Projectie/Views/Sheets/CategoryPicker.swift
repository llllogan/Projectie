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
    
    /// Closure that “returns” the tapped systemName string.
    /// The parent view can implement this closure to receive the selected systemName.
    var onSystemNameSelected: (String) -> Void = { _ in }

    // For automatically dismissing this view when an icon is tapped (optional).
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories) { category in
                    Button {
                        print("Selected systemName: \(category.systemName)")
                        onSystemNameSelected(category.systemName)
                        hapticButtonPress()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .foregroundColor(category.color)
                                    .frame(width: 77, height: 77)
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
                        Text("Remove category")
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

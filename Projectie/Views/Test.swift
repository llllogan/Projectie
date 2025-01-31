//
//  Test.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 30/1/2025.
//

//
//  CustomPagingView.swift
//  ExampleProject
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import Foundation

struct CustomPagingView: View {
    
    @State private var xOffset: CGFloat = 0
    
    @State private var today: Date = Date()
    @State private var timeFrameOffset: Int = 0
    
    @State private var mainID: Int?
    
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    Image(systemName: "progress.indicator")
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                    
                    MockCircleView(item: ItemBalls(title: "Item 1"))
                    .id(-2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                    
                    MockCircleView(item: ItemBalls(title: "Item 2"))
                    .id(-1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                    
                    MockCircleView(item: ItemBalls(title: "Item 3"))
                    .id(0)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                    
                    MockCircleView(item: ItemBalls(title: "Item 4"))
                    .id(1)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                    
                    MockCircleView(item: ItemBalls(title: "Item 5"))
                    .id(2)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.5)
                            .blur(radius: phase.isIdentity ? 0 : 20)
                    }
                    
                    Image(systemName: "progress.indicator")
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                }
                .scrollTargetLayout()
                .offset(x: -29)
            }
            .onScrollPhaseChange { _, newPhase in
                print("Scroll phase: \(newPhase)")
                if (newPhase == .idle) {
                    mainID = 0
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(16, for: .scrollContent)
            .defaultScrollAnchor(.center)
            .scrollPosition(id: $mainID, anchor: .center)
            .onChange(of: mainID ?? 0) { oldValue, newValue in
                handleChangeOfScrollView(oldValue: oldValue, newValue: newValue)
            }
            
            
            Text("\(mainID ?? 99)")
            
            Text("\(today, format: .dateTime.day().month().year())")
        }
    }
    
    func handleChangeOfScrollView(oldValue: Int, newValue: Int) {
        
        let calendar = Calendar.current
        
        if (newValue == 0) {
            return
        }
        
        if (newValue > oldValue) {
            print("Going from \(oldValue) to \(newValue). Moving Forwards")
            today = calendar.date(byAdding: .day, value: 1, to: today)!
        } else {
            print("Going from \(oldValue) to \(newValue). Moving Backwards")
            today = calendar.date(byAdding: .day, value: -1, to: today)!
        }
        
    }
}

struct MockCircleView: View {
    
    var item: ItemBalls
    
    var body: some View {
        
        return ZStack {
            Circle()
                .fill(Color.blue)
                .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
            Text(item.title)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct ItemBalls: Identifiable {
    let id = UUID()
    let title: String
}


// MARK: - SwiftUI Preview

#Preview {
    CustomPagingView()
}

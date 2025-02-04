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
    
    @State private var today: Date = Date()
    @State private var timeFrameOffset: Int = 0
    @State private var directionToMoveInTime: Int = 0
    
    @State private var mainID: Int?
    
    @State private var swipeStartIndex: Int = 0
    @State private var swipeEndIndex: Int = 0
    @State private var overwriteSwipeIndexStart: Bool = true
    
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    Image(systemName: "progress.indicator")
                        .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .repeat(.continuous))
                    
                    MockCircleView(item: ItemBalls(title: "One", timeFrameOffset: timeFrameOffset - 3))
                        .id(-3)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    
                    MockCircleView(item: ItemBalls(title: "Two", timeFrameOffset: timeFrameOffset - 2))
                        .id(-2)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    
                    MockCircleView(item: ItemBalls(title: "Three", timeFrameOffset: timeFrameOffset - 1))
                        .id(-1)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    
                    MockCircleView(item: ItemBalls(title: "Four", timeFrameOffset: timeFrameOffset))
                        .id(0)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    
                    MockCircleView(item: ItemBalls(title: "Five", timeFrameOffset: timeFrameOffset + 1))
                        .id(1)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    MockCircleView(item: ItemBalls(title: "Four", timeFrameOffset: timeFrameOffset + 2))
                        .id(2)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .blur(radius: phase.isIdentity ? 0 : 20)
                        }
                    
                    MockCircleView(item: ItemBalls(title: "Five", timeFrameOffset: timeFrameOffset + 3))
                        .id(3)
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
                    overwriteSwipeIndexStart = true
                    directionToMoveInTime = swipeEndIndex - swipeStartIndex
                    timeFrameOffset += directionToMoveInTime
                    directionToMoveInTime = 0
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(16, for: .scrollContent)
            .defaultScrollAnchor(.center)
            .scrollPosition(id: $mainID, anchor: .center)
            .onChange(of: mainID ?? 0) { oldValue, newValue in
                handleChangeOfScrollView(oldValue: oldValue, newValue: newValue)
            }
            
            
            Text("ID of cirelce: \(mainID ?? 99)")
            Text("Time frame offset: \(timeFrameOffset)")
            
            Text("\(today, format: .dateTime.day().month().year())")
        }
    }
    
    func handleChangeOfScrollView(oldValue: Int, newValue: Int) {
        
        let calendar = Calendar.current
        
        if (newValue == 0) {
            return
        }
        
        print("Going from \(oldValue) to \(newValue). Moving \(newValue > oldValue ? "Forwards" : "Backwards")")
        
        today = calendar.date(byAdding: .day, value: newValue - oldValue, to: today)!
        
        if (overwriteSwipeIndexStart) {
            swipeStartIndex = oldValue
            overwriteSwipeIndexStart = false
        }
        swipeEndIndex = newValue
//        directionToMoveInTime = newValue - oldValue
        
    }
}

struct MockCircleView: View {
    
    var item: ItemBalls
    
    var body: some View {
        
        return ZStack {
            Circle()
                .fill(Color.blue)
                .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
            VStack {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(item.timeFrameOffset)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ItemBalls: Identifiable {
    let id = UUID()
    let title: String
    let timeFrameOffset: Int
}


// MARK: - SwiftUI Preview

#Preview {
    CustomPagingView()
}

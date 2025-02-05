//
//  GoalView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 5/2/2025.
//

import SwiftUI
import Foundation
import Charts

enum DisplayedRemainingTimeGranularity: String {
    case days
    case weeks
    case months
    case years
}

struct GoalView: View {
    
    @State var goal: Goal
    @State var currentBalance: Double
    @State var dateReached: Date?
    
    @State private var granularity: DisplayedRemainingTimeGranularity = .days

    var remainingAmount: Double {
        goal.targetAmount - currentBalance < 0 ? 0 : goal.targetAmount - currentBalance
    }

    var progress: Double {
        currentBalance / goal.targetAmount
    }
    
    func reachInNounText() -> String {
        
        if let dateReached = dateReached {
            
            print(dateReached)
            
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
    
    func reachByNounText() -> String {
        
        if let date = dateReached {
            
            if date == Date() {
                return "Today"
            }
            
            return date.formatted(.dateTime.day().month().year())
        }
        
        return "-"
    }
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                    Text("$\(goal.targetAmount, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                }

                
                Spacer()
                ScalableSectorView(percent: progress)
                    .padding(.vertical, 8)
            }
            .frame(maxHeight: 90)
            
            Divider()
            
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    Text("Achieve By")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(reachByNounText())
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Reach In")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(reachInNounText())
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .onTapGesture {
                    switch granularity {
                    case .days:
                        granularity = .weeks
                    case .weeks:
                        granularity = .months
                    case .months:
                        granularity = .years
                    case .years:
                        granularity = .days
                    }
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Remaining")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(remainingAmount, specifier: "%.2f")")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
            
        }
        
    }
}

struct Sector: Shape {
    var percent: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Determine the center and radius of the circle
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Start at the top of the circle (-90 degrees)
        let startAngle = Angle(degrees: -90)
        // Calculate the end angle based on the percentage (of 360°)
        let endAngle = Angle(degrees: -90 + (360 * percent))
        
        // Draw the sector: start at the center, draw the arc, and close back to the center.
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct ScalableSectorView: View {
    var percent: Double

    var body: some View {
        GeometryReader { geometry in
            // Use the smallest dimension to ensure the view is square.
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Bottom layer: the sector (wedge) that fills the available space.
                Sector(percent: percent)
                    .fill(Color.carrotOrrange)
                
                // Middle layer: a circle that is 80% the size of the available space.
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.7, height: size * 0.7)
                
                // Top layer: percentage text, scaled relative to the available size.
                Text("\(Int(percent * 100))%")
                    .font(.system(size: size * 0.2))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            // Ensure the ZStack takes up a square area based on our computed size.
            .frame(width: size, height: size)
            // Center the content within the available space.
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        // Maintain a square aspect ratio regardless of the parent view.
        .aspectRatio(1, contentMode: .fit)
    }
}

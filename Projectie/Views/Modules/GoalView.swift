//
//  GoalView.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 5/2/2025.
//

import SwiftUI
import Foundation
import Charts

struct GoalView: View {
    // Sample data – in a real app these would be your model values
    let title: String = "Vacation Savings"
    let amount: String = "$5,000"
    let percentageToGoal: Double = 0.65  // 65%
    let daysUntil: Int = 45
    let weeksUntil: Int = 6
    let monthsUntil: Int = 2
    let dateReached: Date? = Date()
    
    @State private var percent: Double = 0.90
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                    Text(amount)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                }

                
                Spacer()
                ScalableSectorView(percent: percent)
                    .padding(.vertical, 8)

            }
            .frame(maxHeight: 90)
            
            Divider()
            
            HStack(alignment: .center, spacing: 50) {
                VStack(alignment: .center) {
                    Text("Achieve On")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(dateReached!, format: .dateTime.day().month().year())")
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .center) {
                    Text("Reach In")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(daysUntil) days")
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .center) {
                    Text("Remaining")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("$450")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
            
        }
        
    }
    

//    var body: some View {
//        VStack(spacing: 20) {
//            
//            HStack(alignment: .bottom) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(title)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                        .fontWeight(.regular)
//                    Text(amount)
//                        .font(.system(size: 30, weight: .bold, design: .rounded))
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
//                
//                ProgressBar(progress: percentageToGoal)
//                    .frame(minWidth: 150, maxHeight: 30)
//                    .padding(.leading, 25)
//                    .padding(.bottom, 10)
//            }
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("You will reach this goal on")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                    if let reachedDate = dateReached {
//                        Text("\(dateFormatter.string(from: reachedDate))")
//                            .font(.title3)
//                            .foregroundColor(.primary)
//                    }
//                }
//                
//                Spacer()
//            }
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Reached In")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                    Text("\(daysUntil) days or \(weeksUntil) weeks or \(monthsUntil) months")
//                        .font(.title3)
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
//            }
//            
//            
//
//
////            HStack {
////                Button(action: {
////                    
////                }) {
////                    Image(systemName: "trash")
////                        .padding(.vertical, 10)
////                }
////                .buttonStyle(.bordered)
////                .tint(.red)
////                
////                Button(action: {
////                    
////                }) {
////                    Image(systemName: "pencil.circle.fill")
////                        .padding(.vertical, 10)
////                }
////                .buttonStyle(.bordered)
////                .tint(.secondary)
////                
////                Button(action: {
////                    
////                }) {
////                    Text("Convert to Transaction")
////                        .padding(.vertical, 10)
////                        .frame(maxWidth: .infinity)
////                }
////                .buttonStyle(.bordered)
////                .tint(.secondary)
////            }
//        }
//    }
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


#Preview {
    GoalView()
}

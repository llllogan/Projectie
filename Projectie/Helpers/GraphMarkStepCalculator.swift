//
//  GraphMarkStepCalculator.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 12/2/2025.
//

import Foundation

/// Returns the optimal divisor `D` (between minD and maxD) such that, when using an interval of
/// maxValue / D, the value `s` falls roughly halfway between ticks.
/// - Parameters:
///   - maxValue: The maximum value of the scale.
///   - s: The “second” value which should lie in the middle of one of the steps.
///   - minD: The minimum allowed divisor (default is 3.0).
///   - maxD: The maximum allowed divisor (default is 6.0).
/// - Returns: A divisor D (between minD and maxD) that best places `s` roughly in the middle of a tick interval.
func computeOptimalDivisor(maxValue: Double, s: Double, minD: Double = 3.0, maxD: Double = 6.0) -> Double? {
    // Ensure s and maxValue are positive.
    guard s > 0, maxValue > 0 else { return nil }
    
    // The ideal condition is:
    //     s = (n + 0.5) * (maxValue / D)
    // which rearranges to:
    //     D = (n + 0.5) * (maxValue / s)
    // for some integer n.
    
    // We want D in [minD, maxD].
    // Solve for n:
    //   minD <= (n+0.5)*maxValue/s <= maxD
    //   => n+0.5 >= minD*s/maxValue and n+0.5 <= maxD*s/maxValue
    //   => n >= (minD*s/maxValue - 0.5) and n <= (maxD*s/maxValue - 0.5)
    let minNDouble = minD * s / maxValue - 0.5
    let maxNDouble = maxD * s / maxValue - 0.5
    let minN = Int(ceil(minNDouble))
    let maxN = Int(floor(maxNDouble))
    
    // Try to see if any integer n gives a candidate divisor in the allowed range.
    if minN <= maxN {
        var bestCandidate: (n: Int, d: Double)?
        // For a simple tie-breaker, we can choose the candidate whose D is closest to the midpoint of [minD, maxD]
        let midD = (minD + maxD) / 2.0
        
        for n in minN...maxN {
            let candidateD = (Double(n) + 0.5) * maxValue / s
            // Double-check candidateD is within allowed range
            if candidateD >= minD && candidateD <= maxD {
                let error = abs(candidateD - midD)
                if bestCandidate == nil || error < abs(bestCandidate!.d - midD) {
                    bestCandidate = (n, candidateD)
                }
            }
        }
        if let candidate = bestCandidate {
            return candidate.d
        }
    }
    
    // If no candidate was found that satisfies the exact ideal condition,
    // search the allowed D range for the one that minimizes the error.
    // The error is defined as the difference between the fractional part of (s * D / maxValue) and 0.5.
    let resolution = 0.001
    var bestD = minD
    var bestError = Double.infinity
    
    for d in stride(from: minD, through: maxD, by: resolution) {
        let tickPosition = s * d / maxValue
        let fractionalPart = tickPosition - floor(tickPosition)
        let error = abs(fractionalPart - 0.5)
        if error < bestError {
            bestError = error
            bestD = d
        }
    }
    
    return bestD
}

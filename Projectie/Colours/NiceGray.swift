//
//  NiceGray.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import SwiftUI
import SwiftData
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIColor {
    static let niceGray = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            // Darker than before (originally 0.8, now 0.4)
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .dark:
            // Even darker in dark mode (originally 0.2, now 0.1)
            return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        @unknown default:
            return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }
}

extension Color {
    static let niceGray = Color(UIColor.niceGray)
}

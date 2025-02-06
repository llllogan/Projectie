//
//  NiceBackground.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 6/2/2025.
//

import SwiftUI
import SwiftData
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIColor {
    static let niceBackground = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            return .secondarySystemBackground
        case .dark:
            return .systemBackground
        @unknown default:
            return .secondarySystemBackground
        }
    }
}

extension Color {
    static let niceBackground = Color(UIColor.niceBackground)
}

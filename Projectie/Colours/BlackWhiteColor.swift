//
//  BlackWhiteColor.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 16/1/2025.
//

import SwiftUI
import Foundation

extension UIColor {
    /// Convenience initializer to create a dynamic color that
    /// is one value in Light Mode and another in Dark Mode.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
}


extension Color {
    static let whiteInDarkBlackInLight = Color(UIColor(light: .black, dark: .white))
}

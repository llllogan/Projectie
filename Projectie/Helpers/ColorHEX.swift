//
//  ColorHEX.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 13/1/2025.
//

import SwiftUI

extension Color {
    /// Initialize a Color from a HEX string.
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        switch length {
        case 6:
            self.init(
                .sRGB,
                red: Double((rgb & 0xFF0000) >> 16) / 255,
                green: Double((rgb & 0x00FF00) >> 8) / 255,
                blue: Double(rgb & 0x0000FF) / 255,
                opacity: 1.0
            )
        case 8:
            self.init(
                .sRGB,
                red: Double((rgb & 0xFF000000) >> 24) / 255,
                green: Double((rgb & 0x00FF0000) >> 16) / 255,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255,
                opacity: Double(rgb & 0x000000FF) / 255
            )
        default:
            return nil
        }
    }

    /// Retrieve the HEX string representation of the Color.
    func toHex(alpha: Bool = false) -> String? {
        #if canImport(UIKit)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        let uiColor = UIColor(self)
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        if alpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255)),
                lroundf(Float(a * 255))
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255))
            )
        }
        #elseif canImport(AppKit)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        let nsColor = NSColor(self)
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        if alpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255)),
                lroundf(Float(a * 255))
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(r * 255)),
                lroundf(Float(g * 255)),
                lroundf(Float(b * 255))
            )
        }
        #else
        return nil
        #endif
    }
}

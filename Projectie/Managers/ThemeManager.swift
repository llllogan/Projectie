//
//  ThemeManager.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 13/2/2025.
//

import SwiftUI

enum AccentTheme: String, Codable {
    case carrotOrrange
    case carrotPurple
    case carrotCustom
}

struct HSBColor: Codable {
    var hue: Double       // 0.0 ... 1.0
    var saturation: Double // 0.0 ... 1.0
    var brightness: Double // 0.0 ... 1.0
    
    
    private static let adjustment: Double = 0.1
    
    
    func lighter(by amount: Double) -> HSBColor {
        HSBColor(
            hue: hue,
            saturation: max(saturation - amount, 0),
            brightness: min(brightness + amount, 1)
        )
    }
    
    func darker(by amount: Double) -> HSBColor {
        HSBColor(
            hue: hue,
            saturation: min(saturation + amount, 1),
            brightness: max(brightness - amount, 0)
        )
    }
    
    func lighter() -> HSBColor {
        lighter(by: HSBColor.adjustment)
    }
    
    func darker() -> HSBColor {
        darker(by: HSBColor.adjustment)
    }
    
    var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    func lighterColor() -> Color {
        lighter().color
    }
    
    func darkerColor() -> Color {
        darker().color
    }
}


extension Color {
    init(hue: Double, saturation: Double, brightness: Double) {
        self.init(UIColor(
            hue: CGFloat(hue),
            saturation: CGFloat(saturation),
            brightness: CGFloat(brightness),
            alpha: 1.0)
        )
    }
    
    
    static let carrotOrrangeHSB = HSBColor(hue: 34/360, saturation: 0.99, brightness: 0.95)
    static let carrotPurpleHSB = HSBColor(hue: 280/360, saturation: 0.75, brightness: 0.9)
    
    static let carrotOrrange = carrotOrrangeHSB.color
    static let carrotPurple = carrotPurpleHSB.color
    
    static let carrotOrrangeLighter = carrotOrrangeHSB.lighterColor()
    static let carrotOrrangeDarker  = carrotOrrangeHSB.darkerColor()
    static let carrotPurpleLighter  = carrotPurpleHSB.lighterColor()
    static let carrotPurpleDarker   = carrotPurpleHSB.darkerColor()
}



final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("hasSetCustomColour") var hasSetCustomColour: Bool = false
    
    @Published var selectedTheme: AccentTheme = .carrotOrrange {
        didSet { saveSelectedTheme() }
    }
    
    @Published var customHSB: HSBColor = HSBColor(hue: 34/360, saturation: 0.99, brightness: 0.95) {
        didSet { saveCustomHSB() }
    }
    
    private let selectedThemeKey = "selectedTheme"
    private let customHSBKey = "customHSB"
    
    init() {
        loadTheme()
    }
    
    var accentHSB: HSBColor {
        switch selectedTheme {
        case .carrotOrrange:
            return Color.carrotOrrangeHSB
        case .carrotPurple:
            return Color.carrotPurpleHSB
        case .carrotCustom:
            return customHSB
        }
    }
    
    var accentColor: Color {
        accentHSB.color
    }
    
    var accentLighter: Color {
        accentHSB.lighterColor()
    }
    
    var accentDarker: Color {
        accentHSB.darkerColor()
    }
    
    private func saveSelectedTheme() {
        if let data = try? JSONEncoder().encode(selectedTheme) {
            UserDefaults.standard.set(data, forKey: selectedThemeKey)
        }
    }
    
    private func saveCustomHSB() {
        if let data = try? JSONEncoder().encode(customHSB) {
            UserDefaults.standard.set(data, forKey: customHSBKey)
        }
    }
    
    private func loadTheme() {
        if let data = UserDefaults.standard.data(forKey: selectedThemeKey),
           let savedTheme = try? JSONDecoder().decode(AccentTheme.self, from: data) {
            self.selectedTheme = savedTheme
        }
        
        if let data = UserDefaults.standard.data(forKey: customHSBKey),
           let savedHSB = try? JSONDecoder().decode(HSBColor.self, from: data) {
            self.customHSB = savedHSB
        }
    }
}

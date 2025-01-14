//
//  Haptics.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 14/1/2025.
//

import UIKit

func hapticButtonPress() {
    let generator = UIImpactFeedbackGenerator()
    generator.prepare()
    generator.impactOccurred()
}

func hapticCancel() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.warning)
}

func hapticSuccess() {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
}

func hapticError() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.error)
}

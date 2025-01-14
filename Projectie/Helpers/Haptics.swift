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

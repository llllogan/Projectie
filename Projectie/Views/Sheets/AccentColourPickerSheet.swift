//
//  AccentColourPickerSheet.swift
//  Projectie
//
//  Created by Logan Janssen | Codify on 13/2/2025.
//

import SwiftUI
import UIKit

struct FullscreenColorPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor: Color = ThemeManager.shared.accentColor
    
    var body: some View {
        FullscreenColorPickerSheet(selectedColor: $selectedColor)
            .onDisappear {
                // When the picker is dismissed, convert the selected Color to HSB and update the theme.
                let uiColor = UIColor(selectedColor)
                var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
                if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                    let newHSB = HSBColor(
                        hue: Double(hue),
                        saturation: Double(saturation),
                        brightness: Double(brightness)
                    )
                    themeManager.customHSB = newHSB
                    themeManager.selectedTheme = .carrotCustom
                    
                    themeManager.hasSetCustomColour = true
                }
            }
    }
}

/// A UIViewControllerRepresentable that wraps our custom UIColorPickerViewController.
struct FullscreenColorPickerSheet: UIViewControllerRepresentable {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: FullscreenColorPickerSheet
        
        init(parent: FullscreenColorPickerSheet) {
            self.parent = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            parent.selectedColor = Color(viewController.selectedColor)
        }
        
        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            parent.selectedColor = Color(viewController.selectedColor)
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let picker = CustomUIColorPickerViewController()
        picker.delegate = context.coordinator
        picker.selectedColor = UIColor(selectedColor)
        picker.doneCallback = {
            dismiss()
        }
        return UINavigationController(rootViewController: picker)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No update needed.
    }
}

/// A custom subclass of UIColorPickerViewController that sets a solid background
class CustomUIColorPickerViewController: UIColorPickerViewController {
    var doneCallback: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    @objc private func doneTapped() {
        doneCallback?()
    }
}

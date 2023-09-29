//
//  SettingsView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI
import Combine

enum Appearance: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    case grey = "Grey"
    case systemDefault = "System Default"
}

extension Appearance {
    func theme(for colorScheme: ColorScheme) -> Theme {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        case .sepia:
            return SepiaTheme()
        case .grey:
            return GreyTheme()
        case .systemDefault:
            return DefaultTheme(colorScheme: colorScheme)
        }
    }
}

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fontManager: FontManager
    @Binding var selectedAppearance: Appearance
    
    var body: some View {
        Form {
            Section(header: Text("Font")) {
                Picker("Font", selection: $fontManager.selectedFont) {
                    ForEach(fontManager.availableFonts, id: \.self) { fontName in
                        Text(fontName).tag(fontName)
                    }
                }
            }
            
            Section(header: Text("Appearance")) {
                Picker("Appearance", selection: $selectedAppearance) {
                    ForEach(Appearance.allCases) { appearance in
                        Text(appearance.rawValue).tag(appearance)
                    }
              }
            }
        }
        .themed(theme: selectedAppearance.theme(for: colorScheme), selectedAppearance: selectedAppearance, isLight: selectedAppearance == .light || (selectedAppearance == .systemDefault && colorScheme == .light))
    }
}

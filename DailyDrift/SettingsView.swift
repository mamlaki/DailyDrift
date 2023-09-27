//
//  SettingsView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI
import Combine

enum Appearance: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case systemDefault = "System Default"
}

struct SettingsView: View {
    @EnvironmentObject var fontManager: FontManager
    @AppStorage("appearance") var storedAppearance: Appearance = .systemDefault
    
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
                Picker("Appearance", selection: $storedAppearance) {
                    ForEach(Appearance.allCases, id: \.self) { appearanceOption in
                        Text(appearanceOption.rawValue).tag(appearanceOption)
                    }
                }
            }
        }
    }
}

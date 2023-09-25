//
//  SettingsView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var fontManager: FontManager
    
    var body: some View {
        Form {
            Section(header: Text("Font")) {
                Picker("Font", selection: $fontManager.selectedFont) {
                    ForEach(fontManager.availableFonts, id: \.self) { fontName in
                        Text(fontName).tag(fontName)
                    }
                }
            }
        }
    }
}

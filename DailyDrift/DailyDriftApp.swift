//
//  DailyDriftApp.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

@main
struct DailyDriftApp: App {
    var fontManager = FontManager()
    @AppStorage("appearance") var appearance: Appearance = .systemDefault
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(fontManager)
                .preferredColorScheme(getColorScheme(from: appearance))
        }
    }
    
    func getColorScheme(from appearance: Appearance) -> ColorScheme? {
        switch appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .systemDefault:
            return nil
        }
    }
}

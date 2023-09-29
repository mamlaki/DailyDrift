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
    @State private var selectedAppearance: Appearance = .systemDefault
    
    var body: some Scene {
        WindowGroup {
            mainView
                .environmentObject(fontManager)
        }
    }
    
    var mainView: some View {
        let view = MainView(selectedAppearance: $selectedAppearance)
        
        switch selectedAppearance {
        case .light:
            return AnyView(view.preferredColorScheme(.light))
        case .dark:
            return AnyView(view.preferredColorScheme(.dark))
        case .sepia:
            return AnyView(view.preferredColorScheme(.light))
        case .systemDefault:
            return AnyView(view.preferredColorScheme(.none))
        }
    }
    
    func getColorScheme(from theme: Theme) -> ColorScheme? {
        switch theme {
        case is LightTheme:
            return .light
        case is DarkTheme:
            return .dark
        case is SepiaTheme:
            return .light
        case is DefaultTheme:
            return nil
        default:
            return nil
        }
    }
}

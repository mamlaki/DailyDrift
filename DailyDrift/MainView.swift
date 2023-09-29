//
//  MainView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fontManager: FontManager
    @Binding var selectedAppearance: Appearance
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(selectedAppearance: $selectedAppearance)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            SettingsView(selectedAppearance: $selectedAppearance)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(1)
        }
        .modifier(ThemeModifier(selectedAppearance: selectedAppearance))
        .environment(\.theme, selectedAppearance.theme(for: colorScheme))
        
    }
}

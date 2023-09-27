//
//  MainView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var fontManager: FontManager
    @State private var selectedTab: Int = 0
    @AppStorage("appearance") var appearance: Appearance = .systemDefault
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(1)
        }
        .onChange(of: appearance) { newAppearance, _ in
            print("New Appearance (MainView): \(newAppearance.rawValue)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(FontManager())
    }
}

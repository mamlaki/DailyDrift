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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(fontManager)
        }
    }
}

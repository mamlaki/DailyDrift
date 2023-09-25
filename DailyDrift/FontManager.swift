//
//  FontManager.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

class FontManager: ObservableObject {
    @Published var selectedFont: String = "System"
    
    let availableFonts: [String] = ["System", "AvenirNext-Regular", "Courier-Bold", "Helvetica Neue", "Times New Roman"]
    
    var currentFontName: String {
        switch selectedFont {
        case "AvenirNext-Regular":
            return "AvenirNext-Regular"
        case "Courier-Bold":
            return "Courier-Bold"
        case "Helvetica Neue":
            return "Helvetica Neue"
        case "Times New Roman":
            return "Times New Roman"
        default:
            return "System"
        }
    }
}

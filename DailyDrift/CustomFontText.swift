//
//  CustomFontText.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-25.
//

import SwiftUI

struct CustomFontText: View {
    var content: String
    var textStyle: UIFont.TextStyle
    var customFontName: String
    
    var fontSize: CGFloat {
        return UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }
    
    init(_ content: String, style: UIFont.TextStyle, customFontName: String) {
        self.content = content
        self.textStyle = style
        self.customFontName = customFontName
    }
    
    var body: some View {
        Text(content).font(.custom(customFontName, size: fontSize))
    }
}

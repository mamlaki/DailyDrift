//
//  NewEntryView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct NewEntryView: View {
    @State private var title = ""
    @State private var content = ""
    @Binding var entries: [Entry]
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextEditor(text: $content)
            Button("Save") {
                let newEntry = Entry(date: Date(), title: title, content: content)
                entries.append(newEntry)
            }
        }
    }
}

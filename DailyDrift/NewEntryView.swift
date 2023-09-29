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
    @Binding var selectedAppearance: Appearance
    @ObservedObject var entryStore: EntryStore
    @Binding var isPresented: Bool
    @Environment(\.theme) var theme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
           
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Entry")
                        .foregroundStyle(Color(UIColor.placeholderText))
                        .padding(.top, 8)
                }
                TextEditor(text: $content)
            }
            
            Button("Add") {
                let newEntry = Entry(date: Date(), title: title, content: content)
                entryStore.add(newEntry)
                isPresented = false
            }
            .disabled(title.isEmpty || content.isEmpty)
        }
        .themed(theme: selectedAppearance.theme(for: colorScheme), selectedAppearance: selectedAppearance, isLight: selectedAppearance == .light || (selectedAppearance == .systemDefault && colorScheme == .light))    }
}

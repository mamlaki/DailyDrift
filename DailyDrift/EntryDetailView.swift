//
//  EntryDetailView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var entryStore: EntryStore
    let entryIndex: Int
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @EnvironmentObject var fontManager: FontManager
    
    init(entryStore: EntryStore, entryIndex: Int) {
        self.entryStore = entryStore
        self.entryIndex = entryIndex
        self._editedTitle = State(initialValue: entryStore.entries[entryIndex].title)
        self._editedContent = State(initialValue: entryStore.entries[entryIndex].content)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entryStore.entries[entryIndex].date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isEditing {
                TextField("Entry Title", text: $editedTitle)
                    .font(.headline)
                    .padding(.bottom, 10)
                
                TextEditor(text: $editedContent)
                    .font(.body)
            } else {
                
                CustomFontText(formattedDate, style: .subheadline, customFontName: fontManager.currentFontName)
                    .padding(.bottom, 5)
                    .foregroundStyle(.gray)
                
                CustomFontText(entryStore.entries[entryIndex].title, style: .headline, customFontName: fontManager.currentFontName)
                    .padding(.bottom, 10)
                
                CustomFontText(entryStore.entries[entryIndex].content, style: .body, customFontName: fontManager.currentFontName)
            }
                Spacer()
        }
        .padding()
        .navigationTitle(isEditing ? "Editing Entry" : entryStore.entries[entryIndex].title)
        .toolbar {
            if isEditing {
                Button(action: {
                    entryStore.updateEntry(at: entryIndex, withTitle: editedTitle, andContent: editedContent)
                    isEditing.toggle()
                }) {
                    Image(systemName: "checkmark.circle")
                }
            } else {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}


struct MainView2_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(FontManager())
    }
}

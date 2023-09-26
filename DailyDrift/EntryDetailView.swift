//
//  EntryDetailView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI
import LocalAuthentication

struct EntryDetailView: View {
    @EnvironmentObject var fontManager: FontManager
    @ObservedObject var entryStore: EntryStore
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isLocked = false
    
    let entryIndex: Int
    
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
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Entry") { success, authError in
                DispatchQueue.main.async {
                    if success {
                        print("Authentication was successful.")
                        isLocked.toggle()
                        entryStore.entries[entryIndex].isLocked = false
                    } else {
                        print("Authentication failed: \(authError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        } else {
            print("Cannot evaluate policy: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isLocked {
                VStack {
                    Text("This entry is locked.")
                    Button("Unlock with FaceID") {
                        authenticate()
                    }
                }
            } else {
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
                Menu {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    .disabled(isLocked)
                    
                    Button(action: {
                        if isLocked {
                            authenticate()
                        } else {
                            isLocked.toggle()
                        }
                    }) {
                        Label(isLocked ? "Unlock" : "Lock", systemImage: isLocked ? "lock.fill" : "lock.open.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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

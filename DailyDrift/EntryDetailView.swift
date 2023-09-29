//
//  EntryDetailView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI
import LocalAuthentication

struct EntryDetailView: View {
    @Environment(\.theme) var theme
    @EnvironmentObject var fontManager: FontManager
    @ObservedObject var entryStore: EntryStore
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var isLocked = false
    @State private var authenticationManager = AuthenticationManager()
    @State private var selectedAppearance: Appearance
    @State private var originalTitle: String
    @State private var originalContent: String
    @State private var showingDiscardConfirmation = false
    @State private var showingSaveConfirmation = false
    @State private var lockedButtonTapped = false
        
    let entryIndex: Int
    
    init(entryStore: EntryStore, entryIndex: Int, selectedAppearance: Appearance) {
        self.entryStore = entryStore
        self.entryIndex = entryIndex
        self._selectedAppearance = State(initialValue: selectedAppearance)
        self._editedTitle = State(initialValue: entryStore.entries[entryIndex].title)
        self._editedContent = State(initialValue: entryStore.entries[entryIndex].content)
        self._isLocked = State(initialValue: entryStore.entries[entryIndex].isLocked)
        self._originalTitle = State(initialValue: entryStore.entries[entryIndex].title)
        self._originalContent = State(initialValue: entryStore.entries[entryIndex].content)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entryStore.entries[entryIndex].date)
    }
    
    func authenticate() {
        authenticationManager.authenticate { success in
            if success {
                isLocked = false
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isLocked {
                ZStack {
                    theme.backgroundColor.ignoresSafeArea()
                    VStack {
                        Text("This entry is locked.")
                        Button("Unlock with FaceID") {
                            authenticate()
                        }
                    }
                }
            } else {
                if isEditing {
                    TextField("Entry Title", text: $editedTitle)
                        .font(.headline)
                        .padding(.bottom, 10)
                
                    TextEditor(text: $editedContent)
                        .font(.body)
                        .background(theme.backgroundColor)
                        .scrollContentBackground(.hidden)
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
            theme.backgroundColor.ignoresSafeArea()
        }
        .padding()
        .modifier(ThemeModifier(selectedAppearance: selectedAppearance))
        .navigationTitle(isEditing ? "Editing Entry" : entryStore.entries[entryIndex].title)
        .toolbar {
            if isEditing {
                HStack {
                    Button(action: {
                        showingDiscardConfirmation = true
                    }) {
                        Image(systemName: "arrow.uturn.backward.circle")
                    }
                    .alert(isPresented: $showingDiscardConfirmation) {
                        Alert(
                            title: Text("Discard Changes"),
                            message: Text("Are you sure you want to discard your changes?"),
                            primaryButton: .destructive(Text("Discard")) {
                                editedTitle = originalTitle
                                editedContent = originalContent
                                isEditing.toggle()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Button(action: {
                        showingSaveConfirmation = true
                     }) {
                         Image(systemName: "checkmark.circle")
                     }
                     .alert(isPresented: $showingSaveConfirmation) {
                         Alert(
                            title: Text("Save Changes"),
                            message: Text("Are you sure you want to save your changes?"),
                            primaryButton: .default(Text("Save")) {
                                entryStore.updateEntry(at: entryIndex, withTitle: editedTitle, andContent: editedContent, isLocked: isLocked)
                                isEditing.toggle()
                            },
                            secondaryButton: .cancel()
                         )
                     }
                }
               
            } else {
                Menu {
                    Button(action: {
                        originalTitle = editedTitle
                        originalContent = editedContent
                        isEditing.toggle()
                    }) {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    .disabled(isLocked)
                    
                    Button(action: {
                        if isLocked {
                            authenticate()
                        } else {
                            lockedButtonTapped = true
                        }
                    }) {
                        Label(isLocked ? "Unlock" : "Lock", systemImage: isLocked ? "lock.fill" : "lock.open.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(isPresented: $lockedButtonTapped) {
            Alert(
                title: Text("Lock Entry"),
                message: Text("Are you sure you want to lock this entry?"),
                primaryButton: .destructive(Text("Lock")) {
                    isLocked = true
                },
                secondaryButton: .cancel {
                    lockedButtonTapped = false
                }
            )
        }
        .onDisappear {
            entryStore.updateLockStatus(at: entryIndex, isLocked: isLocked)
        }
    }
}

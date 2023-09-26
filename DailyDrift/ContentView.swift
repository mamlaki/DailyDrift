//
//  ContentView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

let sampleEntries : [Entry] = [
    Entry(date: Date(timeIntervalSinceNow: -86400*6), title: "Monday Feels", content: "Just another monday... You know, today was actually not that bad. Got a ton of work done, did some hanging out with my cat, had a good meal. Overall it was a pretty great day!"),
    Entry(date: Date(timeIntervalSinceNow: -86400*5), title: "Thoughts", content: "Consciousness is pretty crazy, can't think about it for too long..."),
    Entry(date: Date(timeIntervalSinceNow: -86400*4), title: "A Peaceful Walk", content: "Took a long walk in the park today. The birds were chirping, and a gentle breeze rustled the leaves. Felt a connection with nature that I don't get to feel as much nowadays as I used to."),
].sorted(by: { $0.date > $1.date })

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var fontManager: FontManager
    @ObservedObject var entryStore = EntryStore(entries: sampleEntries)
    @State private var showingNewEntryView = false
    @State private var selectedSortOption: SortOption = .date
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var isDateFilterEnabled = false
    
    
    func deleteEntry(at offsets: IndexSet) {
        entryStore.remove(at: offsets)
    }
    
    enum SortOption {
        case date, title
    }
    
    var filteredEntries: [Entry] {
        let nonPinnedEntries = entryStore.entries.filter { !$0.isPinned }
        let filteredByDateEntries = isDateFilterEnabled ? nonPinnedEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        } : nonPinnedEntries
        
        if searchText.isEmpty {
            return filteredByDateEntries
        } else {
            return filteredByDateEntries.filter { entry in
                entry.title.lowercased().contains(searchText.lowercased()) ||
                entry.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var pinnedEntries: [Entry] {
        return entryStore.entries.filter { $0.isPinned }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isDateFilterEnabled {
                    DatePicker("Filter by Date:", selection: $selectedDate, displayedComponents: [.date])
                        .padding()
                        .disabled(!isDateFilterEnabled)
                        .transition(.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut).combined(with: .move(edge: .top)), removal: AnyTransition.opacity.animation(.easeInOut).combined(with: .move(edge: .top))))
                }
                
                SearchBar(text: $searchText)
                    .animation(.easeInOut, value: isDateFilterEnabled)
                List {
                    if !pinnedEntries.isEmpty {
                        Section(header: Text("Pinned Entries")) {
                            ForEach(pinnedEntries, id: \.self) { entry in
                                entryRow(for: entry)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button(action: {
                                            if let index = entryStore.entries.firstIndex(of: entry) {
                                                entryStore.entries[index].isPinned.toggle()
                                            }
                                        }) {
                                            Label("Unpin", systemImage: "pin.slash")
                                        }
                                        .tint((colorScheme == .light ? Color.yellow : Color.orange))
                                    }
                            }
                            .onDelete(perform: deleteEntry)
                        }
                        
                    }
                    
                    Section(header: Text(isDateFilterEnabled ? "Entries for \(selectedDate, style: .date)" : "All Entries")) {
                        ForEach(filteredEntries, id: \.self) { entry in
                            entryRow(for: entry)
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button(action: {
                                        if let index = entryStore.entries.firstIndex(of: entry) {
                                            entryStore.entries[index].isPinned.toggle()
                                        }
                                    }) {
                                        Label("Pin", systemImage: "pin")
                                    }
                                    .tint((colorScheme == .light ? Color.yellow : Color.orange))
                                }
                        }
                        .onDelete(perform: deleteEntry)
                    }
                }
                .animation(.easeIn(duration: 0.3), value: filteredEntries)
            }
            .navigationTitle("DailyDrift")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack() {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isDateFilterEnabled.toggle()
                            }
                        }) {
                            Image(systemName: isDateFilterEnabled ? "calendar.circle.fill" : "calendar.circle")
                        }
                        Menu {
                            Button(action: {
                                selectedSortOption = .date
                                entryStore.resetToDefaultOrder()
                            }) {
                                HStack {
                                    Text("Recently Added (Default)")
                                    Spacer()
                                    if selectedSortOption == .date {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            Button(action: {
                                selectedSortOption = .title
                                entryStore.sortByTitle()
                            }) {
                                HStack {
                                    Text("Title")
                                    Spacer()
                                    if selectedSortOption == .title {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        Button(action: {
                            showingNewEntryView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewEntryView) {
                NewEntryView(entryStore: self.entryStore, isPresented: $showingNewEntryView)
            }
        }
    }
    
    func entryRow(for entry: Entry) -> some View {
        NavigationLink(destination: EntryDetailView(entryStore: self.entryStore, entryIndex: entryStore.entries.firstIndex(of: entry)!)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.title).font(.headline)
                    Text(entry.content).font(.subheadline).lineLimit(1)
                    Text(entry.formattedDate).font(.caption).foregroundStyle(.gray)
                }
                Spacer()
                Menu {
                    Button(action: {
                        if let index = entryStore.entries.firstIndex(of: entry) {
                            entryStore.entries[index].isPinned.toggle()
                        }
                    }) {
                        Label(
                            entry.isPinned ? "Unpin" : "Pin",
                            systemImage: entry.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    Button(action: {
                        if let index = entryStore.entries.firstIndex(of: entry) {
                            entryStore.remove(at: [index])
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .padding(.trailing, 2)
            TextField("Find in Entries", text: $text)
                .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

#Preview {
    ContentView()
}

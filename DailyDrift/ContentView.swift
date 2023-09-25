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
    @State private var showingNewEntryView = false
    @State private var selectedSortOption: SortOption = .date
    @State private var searchText = ""
    @ObservedObject var entryStore = EntryStore(entries: sampleEntries)
    
    func deleteEntry(at offsets: IndexSet) {
        entryStore.remove(at: offsets)
    }
    
    enum SortOption {
        case date, title
    }
    
    var filteredEntries: [Entry] {
        if searchText.isEmpty {
            return entryStore.entries
        } else {
            return entryStore.entries.filter { entry in
                entry.title.lowercased().contains(searchText.lowercased()) ||
                entry.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                List {
                    ForEach(filteredEntries, id: \.self) { entry in
                        NavigationLink(destination: EntryDetailView(entryStore: self.entryStore, entryIndex: entryStore.entries.firstIndex(of: entry)!)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.title).font(.headline)
                                    Text(entry.content).font(.subheadline).lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let index = entryStore.entries.firstIndex(of: entry) {
                                        entryStore.remove(at: [index])
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteEntry)
                }
            }
            .navigationTitle("Journal Entries")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack() {
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

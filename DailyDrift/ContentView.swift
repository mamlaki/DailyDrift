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
]

struct ContentView: View {
    @State private var showingNewEntryView = false
    @ObservedObject var entryStore = EntryStore(entries: sampleEntries)
    
    var body: some View {
        NavigationView {
            List(entryStore.entries, id: \.self) { entry in
                VStack(alignment: .leading) {
                    Text(entry.title).font(.headline)
                    Text(entry.content).font(.subheadline).lineLimit(1)
                }
            }
            .navigationTitle("Journal Entries")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingNewEntryView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntryView) {
                NewEntryView(entryStore: entryStore)
            }
        }
    }
}

#Preview {
    ContentView()
}

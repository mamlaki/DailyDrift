//
//  EntryStore.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

class EntryStore: ObservableObject {
    @Published var entries: [Entry] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private var originalEntries : [Entry] = []
    
    init(entries: [Entry] = []) {
        self.entries = entries
        self.originalEntries = entries
    }
    
    func add(_ entry: Entry) {
        entries.insert(entry, at: 0)
        originalEntries.insert(entry, at: 0)
    }
    
    func remove(at offsets: IndexSet) {
        if let firstOffset = offsets.first {
            originalEntries.removeAll { $0 == entries[firstOffset] }
        }
        entries.remove(atOffsets: offsets)
    }
    
    func updateEntry(at index: Int, withTitle title: String, andContent content: String) {
        entries[index].title = title
        entries[index].content = content
        
        if let originalIndex = originalEntries.firstIndex(where: { $0.id == entries[index].id }) {
            originalEntries[originalIndex].title = title
            originalEntries[originalIndex].content = content
        }
    }
    
    func sortByTitle() {
        entries.sort { $0.title < $1.title}
    }
    
    func resetToDefaultOrder() {
        entries = originalEntries.sorted(by: {$0.date > $1.date })
    }
    
    private func saveToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encodedData, forKey: "entries")
        }
    }
    
    private func loadFromUserDefaults() -> [Entry]? {
        if let savedEntries = UserDefaults.standard.data(forKey: "entries"),
           let decodedEntries = try? JSONDecoder().decode([Entry].self, from: savedEntries) {
            return decodedEntries
        }
        return nil
    }
}

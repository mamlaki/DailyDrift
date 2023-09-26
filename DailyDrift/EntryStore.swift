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
    
    private var originalEntries : [Entry]
    
    init(entries: [Entry] = []) {
        let loadedEntries = Self.loadFromUserDefaults() ?? entries
        self.entries = loadedEntries
        self.originalEntries = loadedEntries
    }
    
    func add(_ entry: Entry) {
        entries.insert(entry, at: 0)
        originalEntries.insert(entry, at: 0)
        saveToUserDefaults()
    }
    
    func remove(at offsets: IndexSet) {
        if let firstOffset = offsets.first {
            originalEntries.removeAll { $0 == entries[firstOffset] }
        }
        entries.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    func updateEntry(at index: Int, withTitle title: String, andContent content: String, isLocked: Bool = false) {
        self.entries[index].title = title
        self.entries[index].content = content
        self.entries[index].isLocked = isLocked
        
        if let originalIndex = originalEntries.firstIndex(where: { $0.id == entries[index].id }) {
            originalEntries[originalIndex].title = title
            originalEntries[originalIndex].content = content
            originalEntries[originalIndex].isLocked = isLocked
        }
        print("isLocked in EntryStore: \(entries[index].isLocked)")
        saveToUserDefaults()
    }
    
    func updateLockStatus(at index: Int, isLocked: Bool) {
        self.entries[index].isLocked = isLocked
        if let originalIndex = originalEntries.firstIndex(where: { $0.id == entries[index].id }) {
            self.originalEntries[originalIndex].isLocked = isLocked
        }
        saveToUserDefaults()
    }
    
    func sortByTitle() {
        let currentPinStatuses = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0.isPinned) })
        entries.sort { $0.title < $1.title}
        for index in entries.indices {
            entries[index].isPinned = currentPinStatuses[entries[index].id] ?? false
        }
    }
    
    func resetToDefaultOrder() {
        let currentPinStatuses = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0.isPinned) })
        entries = originalEntries.sorted(by: {$0.date > $1.date })
        for index in entries.indices {
            entries[index].isPinned = currentPinStatuses[entries[index].id] ?? false
        }
    }
    
    private func saveToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encodedData, forKey: "entries")
        }
    }
    
    private static func loadFromUserDefaults() -> [Entry]? {
        if let savedEntries = UserDefaults.standard.data(forKey: "entries"),
           let decodedEntries = try? JSONDecoder().decode([Entry].self, from: savedEntries) {
            return decodedEntries
        }
        return nil
    }
}

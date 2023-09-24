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
        entries.append(entry)
        originalEntries.append(entry)
    }
    
    func remove(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    func sortByTitle() {
        entries.sort { $0.title < $1.title}
    }
    
    func resetToDefaultOrder() {
        entries = originalEntries
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

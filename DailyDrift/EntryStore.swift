//
//  EntryStore.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

class EntryStore: ObservableObject {
    @Published var entries: [Entry]
    
    init(entries: [Entry] = []) {
        self.entries = entries
    }
    
    func add(_ entry: Entry) {
        entries.append(entry)
    }
}

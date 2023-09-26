//
//  Entry.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct Entry: Identifiable, Hashable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var title: String
    var content: String
    var isPinned: Bool = false
    var isLocked: Bool = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

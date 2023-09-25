//
//  EntryDetailView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(entry.content)
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle(entry.title)
    }
}

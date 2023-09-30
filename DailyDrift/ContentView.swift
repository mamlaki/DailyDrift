//
//  ContentView.swift
//  DailyDrift
//
//  Created by Melek Redwan on 2023-09-24.
//

import SwiftUI
import UIKit

struct CustomTitleView: UIViewRepresentable {
    var title: String
    var color: UIColor
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = title
        uiView.textColor = color
    }
}

let sampleEntries : [Entry] = [
    Entry(date: Date(timeIntervalSinceNow: -86400*6), title: "Monday Feels", content: "Just another monday... You know, today was actually not that bad. Got a ton of work done, did some hanging out with my cat, had a good meal. Overall it was a pretty great day!"),
    Entry(date: Date(timeIntervalSinceNow: -86400*5), title: "Thoughts", content: "Consciousness is pretty crazy, can't think about it for too long..."),
    Entry(date: Date(timeIntervalSinceNow: -86400*4), title: "A Peaceful Walk", content: "Took a long walk in the park today. The birds were chirping, and a gentle breeze rustled the leaves. Felt a connection with nature that I don't get to feel as much nowadays as I used to."),
].sorted(by: { $0.date > $1.date })

struct DraggableSeparator: View {
    @Binding var percentage: CGFloat
    @State private var initialPercentage: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(Color.gray)
            .frame(width: UIScreen.main.bounds.width)
            .gesture(DragGesture(coordinateSpace: .named("CustomCoordinateSpace"))
                .onChanged { value in
                    let dragHeight = value.startLocation.y + value.translation.height - 300
                    let newPercentage = dragHeight / (UIScreen.main.bounds.height - 300)
                    self.percentage = constraingPercentage(newPercentage)
                }
                .onEnded { value in
                    let dragHeight = value.startLocation.y + value.translation.height - 300
                    let newPercentage = dragHeight / (UIScreen.main.bounds.height - 300)
                    self.percentage = constraingPercentage(newPercentage)
                }
            )
    }
    
    func constraingPercentage(_ percentage: CGFloat) -> CGFloat {
        let toolbarHeight: CGFloat = 50
        let tabViewHeight: CGFloat = 300
        let lowerBound: CGFloat = toolbarHeight / UIScreen.main.bounds.height
        let upperBound: CGFloat = 1 - (tabViewHeight / UIScreen.main.bounds.height)
        return min(max(percentage, lowerBound), upperBound)
    }
}

struct ContentView: View {
    @Binding var selectedAppearance: Appearance
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme) var theme
    @EnvironmentObject var fontManager: FontManager
    @StateObject var entryStore = EntryStore(entries: sampleEntries)
    @State private var showingNewEntryView = false
    @State private var selectedSortOption: SortOption = .date
    @State private var searchText = ""
    @State private var selectedDate = Date()
    @State private var isDateFilterEnabled = false
    @State private var authenticationManager = AuthenticationManager()
    @State private var currentAlert: AlertType?
    @State private var currentIndex: Int?
    @State private var pendingDeleteAuthentication = false
    @State private var isEditing = false
    @State private var isEditingPinned = false
    @State private var percentage: CGFloat = 0.5
    
    func deleteEntry(at offsets: IndexSet) {
        entryStore.remove(at: offsets)
    }
    
    enum SortOption {
        case date, title, custom
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
    
    var editMode: Binding<EditMode> {
        Binding<EditMode>(
            get: { self.isEditing ? .active : .inactive },
            set: { self.isEditing = $0 == .active }
        )
    }
    
    var editModePinned: Binding<EditMode> {
        Binding<EditMode>(
            get: { self.isEditingPinned ? .active : .inactive },
            set: { self.isEditingPinned = $0 == .active}
        )
    }
    
    var body: some View {
        NavigationView {
            NavigationStack {
                VStack {
                    if isDateFilterEnabled {
                        DatePicker("Filter by Date:", selection: $selectedDate, displayedComponents: [.date])
                            .padding()
                            .disabled(!isDateFilterEnabled)
                            .transition(.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut).combined(with: .move(edge: .top)), removal: AnyTransition.opacity.animation(.easeInOut).combined(with: .move(edge: .top))))
                    }
                    
                    SearchBar(text: $searchText)
                        .animation(.easeInOut, value: isDateFilterEnabled)
                    if !pinnedEntries.isEmpty {
                        List {
                            Section(header:
                                HStack {
                                    Text("Pinned Entries")
                                    Button(action: {
                                        withAnimation {
                                            self.isEditingPinned.toggle()
                                        }
                                    }) {
                                        Image(systemName: self.isEditingPinned ? "pencil.circle.fill" : "pencil.circle")
                                    }
                                }
                                .disabled(self.selectedSortOption != .custom)
                            ) {
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
                                .onMove(perform: entryStore.movePinned)
                            }
                        }
                        .themed(theme: selectedAppearance.theme(for: colorScheme), selectedAppearance: selectedAppearance, isLight: selectedAppearance == .light || (selectedAppearance == .systemDefault && colorScheme == .light))
                        .animation(.easeIn(duration: 0.3), value: filteredEntries)
                        .frame(height: UIScreen.main.bounds.height * percentage)
                        .environment(\.editMode, self.editModePinned)
                    }
                    
                    DraggableSeparator(percentage: $percentage)
                        .frame(height: 30)
                    
                    List {
                        Section(header:
                            HStack {
                                Text(isDateFilterEnabled ? "Entries for \(selectedDate, style: .date)" : "All Entries")
                                Button(action: {
                                    withAnimation {
                                        self.isEditing.toggle()
                                    }
                                }) {
                                    Image(systemName: self.isEditing ? "pencil.circle.fill" : "pencil.circle")
                                }
                                .disabled(self.selectedSortOption != .custom)
                            }
                        ) {
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
                            .onMove(perform: entryStore.move)
                        }
                    }
                    .themed(theme: selectedAppearance.theme(for: colorScheme), selectedAppearance: selectedAppearance, isLight: selectedAppearance == .light || (selectedAppearance == .systemDefault && colorScheme == .light))
                    .animation(.easeIn(duration: 0.3), value: filteredEntries)
                    .frame(height: UIScreen.main.bounds.height * (1 - percentage))
                    .environment(\.editMode, self.editMode)
                }
                .coordinateSpace(name: "CustomCoordinateSpace")
                .background(selectedAppearance.theme(for: colorScheme).backgroundColor.ignoresSafeArea(.all))
                .navigationBarTitleDisplayMode(.inline)
                .padding(.top, 300)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        CustomTitleView(title: "DailyDrift", color: UIColor(selectedAppearance.theme(for: colorScheme).primaryColor))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack() {
                            Text("\(weeklyEntryCount())")
                            Menu {
                                Text(weeklyEntryCount() == 0 ? "No entries this week" : "\(weeklyEntryCount()) \(weeklyEntryCount() == 1 ? "entry" : "entries") this week")
                            } label: {
                                Image(systemName: "trophy.circle")
                            }
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
                                Button(action: {
                                    selectedSortOption = .custom
                                    entryStore.resetToCustomOrder()
                                }) {
                                    HStack {
                                        Text("Custom")
                                        Spacer()
                                        if (selectedSortOption == .custom) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                            .disabled(isEditing || isEditingPinned)
                            Button(action: {
                                showingNewEntryView = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .toolbarBackground(selectedAppearance.theme(for: colorScheme).backgroundColor, for: .navigationBar)
                .sheet(isPresented: $showingNewEntryView) {
                    NewEntryView(selectedAppearance: $selectedAppearance, entryStore: self.entryStore, isPresented: $showingNewEntryView)
                }
            }
        }

    }
    
    func entryRow(for entry: Entry) -> some View {
        NavigationLink(destination: EntryDetailView(entryStore: self.entryStore, entryIndex: entryStore.entries.firstIndex(of: entry)!, selectedAppearance: selectedAppearance)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.title).font(.headline)
                    Text(entry.content).font(.subheadline).lineLimit(1)
                    Text(entry.formattedDate).font(.caption).foregroundStyle(.gray)
                }
                Spacer()
                
                if entry.isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                }
                
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
                            currentIndex = index
                            if entryStore.entries[index].isLocked {
                                authenticationManager.authenticate { success in
                                    if success {
                                        entryStore.entries[index].isLocked = false
                                    }
                                }
                            } else {
                                currentAlert = .lock
                            }
                        }
                    }) {
                        Label (
                            entry.isLocked ? "Unlock" : "Lock",
                            systemImage: entry.isLocked ? "lock.open" : "lock"
                        )
                    }
                    Button(action: {
                        if let index = entryStore.entries.firstIndex(of: entry) {
                            currentIndex = index
                            if entry.isLocked {
                                authenticationManager.authenticate { success in
                                    if success {
                                        entryStore.entries[index].isLocked = false
                                        currentAlert = .delete
                                    }
                                }
                            }
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .alert(item: $currentAlert) { alertType in
                    switch alertType {
                    case .lock:
                        return Alert(
                            title: Text("Lock Entry"),
                            message: Text("Are you sure you wnat to lock this entry?"),
                            primaryButton: .destructive(Text("Lock")) {
                                if let index = currentIndex {
                                    entryStore.entries[index].isLocked = true
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    case .delete:
                        return Alert(
                            title: Text("Delete Entry"),
                            message: Text("Are you sure you want to delete this entry? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                if let index = currentIndex {
                                    entryStore.remove(at: [index])
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
               
            }
            .opacity(entry.isLocked ? 0.5 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func isEntryWithinThisWeek(date: Date) -> Bool {
        let startOfWeek = Calendar.current.startOfDay(for: Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!)
        
        return date >= startOfWeek && date < Date()
    }

    func weeklyEntryCount() -> Int {
        return entryStore.entries.filter { isEntryWithinThisWeek(date: $0.date) }.count
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(selectedAppearance: .constant(.light))
            .environmentObject(FontManager())
    }
}

//
//  ContentView.swift
//  TermCalendar
//
//  Created by Michael Rockhold on 1/11/22.
//

import SwiftUI
import EventKit

extension UUID: Identifiable {
    public var id: String {
        self.uuidString
    }
    
    static let zero = UUID()
}

struct ContentView: View {
    
    private let store: EKEventStore
    private let calendars: [UUID:EKCalendar]
    private let calendarIDs: [UUID]
    
    @State private var titleText = ""
    @State private var footnoteText = ""
    
    @State private var selectedCalendar = UUID.zero
    
    @State private var firstDayPickerSelection = Date()
    @State private var lastDayPickerSelection = Date()
    
    init(store s: EKEventStore) {
        store = s
        var cals = [UUID:EKCalendar]()
        var calIDs = [UUID]()
        store.calendars(for: .event)
            .forEach { cal in
                let id = UUID(uuidString: cal.calendarIdentifier)!
                calIDs.append(id)
                cals[id] = cal
            }
        calendarIDs = calIDs
        calendars = cals
    }
    
    func saveNotAvailable() -> Bool {
        return !(titleText != ""
                 && footnoteText != ""
                 && firstDayPickerSelection.advanced(by: 60*60*24*60) < lastDayPickerSelection
                 && selectedCalendar != UUID.zero)
    }
    
    var body: some View {
        
        Spacer()
        Form {
            Picker(selection: $selectedCalendar,
                   label: Label("Calendar", systemImage: "calendar")) {
                
                ForEach(calendarIDs) { calID in
                    Text(calendars[calID]!.title).tag(calID)
                }
            }
            
            TextField("Title", text: $titleText)
            
            TextField("Footnote", text: $footnoteText)
            
            DatePicker("First Day",
                       selection: $firstDayPickerSelection,
                       displayedComponents: [.date])
                .onChange(of: firstDayPickerSelection) {newValue in
                    print(newValue)
                }
            
            DatePicker("Last Day",
                       selection: $lastDayPickerSelection,
                       displayedComponents: [.date])
                .onChange(of: lastDayPickerSelection) {newValue in
                    print(newValue)
                }
            
            Button(action: {
                
                createCalendarGrid()
                
            }) {
                Label("Open in Browser", systemImage: "safari")
            }
            .disabled(saveNotAvailable())
        }
        .padding()
        Spacer()
    }
    
    
    func createCalendarGrid() {
        
        guard let eventCalendar = store.calendar(where: { c in UUID(uuidString: c.calendarIdentifier)! == selectedCalendar }) else {
            
            print(Quartermaster.QuartermasterError.NoMatchingCalendar)
            return
        }
        let events = store.events(matching: store.predicateForEvents(withStart: firstDayPickerSelection,
                                                                     end: lastDayPickerSelection,
                                                                     calendars: [eventCalendar]))
        
        do {
            let q = try Quartermaster(events: events,
                                      firstDay: firstDayPickerSelection,
                                      lastDay: lastDayPickerSelection,
                                      title: titleText,
                                      footnote: footnoteText)
            let document = Presenter(q, weekWidth: 5).present()
            let text = document.emit()
            
            // generate temporary file
            let filemanager = FileManager.default
            let tempDirURL = filemanager.temporaryDirectory
            let fileURL = tempDirURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("html")
            
            // write content to it
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // open it in Safari
            NSWorkspace.shared.open(fileURL)
            
        }
        catch {
            print(error)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: EKEventStore.getStore())
    }
}

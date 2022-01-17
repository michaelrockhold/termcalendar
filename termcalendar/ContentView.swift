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
                print("SAVING")
                print("Title : \(titleText)")
                print("Footer: \(footnoteText)")
                print("Selected Calendar: \(selectedCalendar)")
                
                
                
                
                
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(saveNotAvailable())
            
            NavigationLink("Link to Calendar Document", destination: Text("file:///var/foo.html"))

        }
        .padding()
        Spacer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: EKEventStore.getStore())
    }
}

func save() {
    print("SAVING CALENDAR FILE")
}

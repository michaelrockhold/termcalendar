//
//  TermCalendarApp.swift
//  TermCalendar
//
//  Created by Michael Rockhold on 1/11/22.
//

import SwiftUI
import EventKit

@main
struct TermCalendarApp: App {
    
    let store = EKEventStore.getStore()
    
    var body: some Scene {
        
        WindowGroup {
            ContentView(store: store)
        }
    }
}

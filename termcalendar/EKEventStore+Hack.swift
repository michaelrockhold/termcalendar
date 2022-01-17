//
//  EKEventStore+Hack.swift
//  termcalendar
//
//  Created by Michael Rockhold on 1/13/22.
//

import Foundation
import EventKit

extension EKEventStore {
    static func getStore() -> EKEventStore {
        
        // Stupid little Hack, discovered by Dirk Scheidt for the ReminderListExport project
        // https://mitt-woch.de/images/media/ReminderListExport.zip
        // It serves here as a replacement for the EKEventStore constructor.
        let store = EventKitHack().permCheck()
        
        guard #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *) else {
            print("Unsupported OS version error")
            fatalError()
        }
        
        store.reset()
        
        let _ = Task {
            do  {
                let ok = try await store.requestAccess(to: .event)
                guard ok else { fatalError() }
            }
            catch {
                fatalError()
            }
        }
        return store
    }
        
    func calendar(where f: (EKCalendar)->Bool) -> EKCalendar? {
        for c in self.calendars(for: .event) {
            if f(c) { return c }
        }
        return nil
    }
}

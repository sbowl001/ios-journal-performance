//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        print("sync starting")
        self.context.perform {
            var identifiers: [String] = []
            
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                identifiers.append(identifier)
            }
            
            let coreDataEntries = self.fetchEntriesFromPersistentStore(with: identifiers, in: self.context)
            
            var dictionaryLookUp: [String: Entry] = [:]
            
            if let coreDataEntries = coreDataEntries{
                for entry in coreDataEntries {
                    guard let identifier = entry.identifier else {continue}
                    
                    dictionaryLookUp[identifier] = entry
                }
            }
            
            for entryRep in entries {
                guard let identifier = entryRep.identifier else {continue}
                let coreDataEntry = dictionaryLookUp[identifier]
                if let coreDataEntry = coreDataEntry, coreDataEntry != entryRep{
                    self.update(entry: coreDataEntry, with: entryRep)
                } else if coreDataEntry == nil{
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
 
//            for entryRep in entries {
//                guard let identifier = entryRep.identifier else { continue }
//
//                let entry = self.fetchSingleEntryFromPersistentStore(with: identifier, in: self.context)
//                if let entry = entry, entry != entryRep {
//                    self.update(entry: entry, with: entryRep)
//                } else if entry == nil {
//                    _ = Entry(entryRepresentation: entryRep, context: self.context)
//                }
//            }
//            completion(nil)
//            print("sync ended" )
            completion(nil)
        }
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    private func fetchEntriesFromPersistentStore(with identifiers: [String], in context: NSManagedObjectContext) -> [Entry]? {
        
   
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
//        var result: Entry? = nil
        var result: [Entry]? = nil
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching entries: \(error)")
        }
//        return result
        return result 
    }
    
    let context: NSManagedObjectContext
}
//    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
//
//        guard let identifier = identifier else { return nil }
//
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifier)
//
//        var result: Entry? = nil
//        do {
//            result = try context.fetch(fetchRequest).first
//        } catch {
//            NSLog("Error fetching single entry: \(error)")
//        }
//        return result
//    }
//
//    let context: NSManagedObjectContext
//}

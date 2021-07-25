//
//  CharSetCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import SwiftUI

var CharSets = CharSetCatalog()

class CharSetCatalog: ObservableObject {
    @Published var documentPath: String? = nil
    @Published var documents: Array<String> = []
    
    func document() -> CharSetDocument? {
        trimSets()
        if let file = documentPath {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
            if FileManager.default.fileExists(atPath: path.path) {
                return CharSetDocument(from: FileManager.default.contents(atPath: path.path)!)
            } else {
                documentPath = nil
                if documents.count > 0 {
                    documentPath = documents.first!
                }
                return document()
            }
        } else {
            return nil
        }
    }
    
    func trimSets() {
        for file in documents {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file).path
            if !FileManager.default.fileExists(atPath: path) {
                documents.remove(at: documents.firstIndex(of: file)!)
            }
        }
    }
    
    func saveSets() {
        trimSets()
        let manager = FilesManager()
        do {
            try manager.delete(fileNamed: "charsets.json")
        } catch { print("error saving charsets: \(error)") }
        do {
            try manager.save(fileNamed: "charsets.json", data: JSONEncoder().encode(documents))
        } catch { print("error saving charsets: \(error)") }
    }

    func loadSets() {
        let manager = FilesManager()
        do {
            self.documents = try JSONDecoder().decode(Array<String>.self, from: try manager.read(fileNamed: "charsets.json"))
        } catch { print("error loading charsets: \(error)") }
        trimSets()
        if documents.count > 0 {
            documentPath = documents.first!
        }
    }
}

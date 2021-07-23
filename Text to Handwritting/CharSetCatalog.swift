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
    @Published var document: CharSetDocument? = nil
    @Published var documents: Array<String> = []
    
    func saveSets() {
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
    }
}

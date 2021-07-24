//
//  TemplateCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

var Templates = TemplateCatalog()

class TemplateCatalog: ObservableObject {
    @Published var document: TemplateDocument? = nil
    @Published var documents: Array<String> = []
    
    func trimTemplates() {
        for file in documents {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file).path
            if !FileManager.default.fileExists(atPath: path) {
                documents.remove(at: documents.firstIndex(of: file)!)
            }
        }
    }
    
    func saveTemplates() {
        trimTemplates()
        let manager = FilesManager()
        do {
            try manager.delete(fileNamed: "templates.json")
        } catch { print("error saving templates: \(error)") }
        do {
            try manager.save(fileNamed: "templates.json", data: JSONEncoder().encode(documents))
        } catch { print("error saving templates: \(error)") }
    }

    func loadTemplates() {
        let manager = FilesManager()
        do {
            self.documents = try JSONDecoder().decode(Array<String>.self, from: try manager.read(fileNamed: "templates.json"))
        } catch { print("error loading templates: \(error)") }
        trimTemplates()
    }
}

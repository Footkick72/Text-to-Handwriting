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
    @Published var documentPath: String? = nil
    @Published var documents: Array<String> = []
    
    func document() -> TemplateDocument? {
        trimTemplates()
        if let file = documentPath {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
            if FileManager.default.fileExists(atPath: path.path) {
                return TemplateDocument(from: FileManager.default.contents(atPath: path.path)!)
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
        if documents.count > 0 {
            documentPath = documents.first!
        }
    }
}

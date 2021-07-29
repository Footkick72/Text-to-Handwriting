//
//  Catalog.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/25/21.
//


import Foundation
import SwiftUI

var CharSets = CharSetCatalog()
var Templates = TemplateCatalog()

typealias TemplateCatalog = Catalog<TemplateDocument>
typealias CharSetCatalog = Catalog<CharSetDocument>

class Catalog<DocType: HandwritingDocument>: ObservableObject {
    @Published var documentPath: URL? = nil
    @Published var documents: Array<URL> = []
    
    func document() -> DocType? {
        trim()
        if let file = documentPath {
            if FileManager.default.fileExists(atPath: file.path) {
                return DocType(from: FileManager.default.contents(atPath: file.path)!)
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
    
    func findNewTemplate() {
        if documentPath == nil {
            if documents.count > 0 {
                documentPath = documents.first!
            } else if DocType.defaults.count > 0 {
                documentPath = DocType.defaults.keys.first!
            }
        }
    }
    
    func deleteObject(at: Int) {
        if documents[at] == documentPath {
            documentPath = nil
        }
        documents.remove(at: at)
        findNewTemplate()
    }
    
    func isSelectedDocument(path: URL) -> Bool {
        return documentPath == path
    }
    
    func trim() {
        for file in documents {
            if !FileManager.default.fileExists(atPath: file.path) {
                documents.remove(at: documents.firstIndex(of: file)!)
            }
        }
        if documentPath != nil && !FileManager.default.fileExists(atPath: documentPath!.path) {
            documentPath = nil
        }
    }
    
    func save() {
        trim()
        let manager = FilesManager()
        do {
            try manager.delete(fileNamed: DocType.defaultSaveFile)
        } catch { print("error saving: \(error)") }
        do {
            if documentPath != nil {
                documents.append(documentPath!)
            } else {
                documents.append(URL(string: "randomnonscenceurl812748921)(*&@")!)
            }
            try manager.save(fileNamed: DocType.defaultSaveFile, data: JSONEncoder().encode(documents))
        } catch { print("error saving: \(error)") }
    }

    func load() {
        let manager = FilesManager()
        do {
            self.documents = try JSONDecoder().decode(Array<URL>.self, from: try manager.read(fileNamed: DocType.defaultSaveFile))
            self.documentPath = self.documents.popLast()
        } catch { print("error loading: \(error)") }
        trim()
        findNewTemplate()
    }
}

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
    
    func deleteObject(at: Int) {
        if documents[at] == documentPath {
            documentPath = nil
        }
        documents.remove(at: at)
        if documents.count > 0 && documentPath == nil {
            documentPath = documents.first!
        }
    }
    
    func isSelectedDocument(at: Int) -> Bool {
        return documents[at] == documentPath
    }
    
    func isSelectedDocument(_ d: DocType.ObjectType) -> Bool {
        return document()?.object == d
    }
    
    func trim() {
        for file in documents {
            if !FileManager.default.fileExists(atPath: file.path) {
                documents.remove(at: documents.firstIndex(of: file)!)
            }
        }
    }
    
    func save() {
        trim()
        let manager = FilesManager()
        do {
            try manager.delete(fileNamed: DocType.defaultSaveFile)
        } catch { print("error saving: \(error)") }
        do {
            try manager.save(fileNamed: DocType.defaultSaveFile, data: JSONEncoder().encode(documents))
        } catch { print("error saving: \(error)") }
    }

    func load() {
        let manager = FilesManager()
        do {
            self.documents = try JSONDecoder().decode(Array<URL>.self, from: try manager.read(fileNamed: DocType.defaultSaveFile))
        } catch { print("error loading: \(error)") }
        trim()
        if documents.count > 0 {
            documentPath = documents.first!
        }
    }
}

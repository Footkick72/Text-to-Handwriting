//
//  Catalog.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/25/21.
//


import Foundation
import SwiftUI

//var Templates = TemplateCatalog()

protocol HandwritingDocument {
    static var defaultSaveFile: String { get }
    init(from: Data)
}

var CharSets = CharSetCatalog()
var Templates = TemplateCatalog()

typealias TemplateCatalog = Catalog<TemplateDocument>
typealias CharSetCatalog = Catalog<CharSetDocument>

class Catalog<DocType: HandwritingDocument>: ObservableObject {
    @Published var documentPath: String? = nil
    @Published var documents: Array<String> = []
    
    func document() -> DocType? {
        trim()
        if let file = documentPath {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
            if FileManager.default.fileExists(atPath: path.path) {
                return DocType(from: FileManager.default.contents(atPath: path.path)!)
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
    
    func trim() {
        for file in documents {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file).path
            if !FileManager.default.fileExists(atPath: path) {
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
            self.documents = try JSONDecoder().decode(Array<String>.self, from: try manager.read(fileNamed: DocType.defaultSaveFile))
        } catch { print("error loading: \(error)") }
        trim()
        if documents.count > 0 {
            documentPath = documents.first!
        }
    }
}

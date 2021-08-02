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
                documentPath = DocType.defaults.keys.sorted(by: {a, b in
                    return a.lastPathComponent < b.lastPathComponent
                }).first!
            }
        }
    }
    
    func deleteObject(at: Int) {
        if documents[at] == documentPath {
            documentPath = nil
        }
        documents.remove(at: at)
        findNewTemplate()
        save()
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
        if documents.count != 0 {
            let bookmarks = documents.map() { try! $0.bookmarkData() }
            UserDefaults.standard.setValue(bookmarks, forKey: DocType.defaultSaveFile + "DocumentList")
        } else {
            UserDefaults.standard.setValue(nil, forKey: DocType.defaultSaveFile + "DocumentList")
        }
        
        if let documentPath = documentPath  {
            let selectedBookmark = try! documentPath.bookmarkData()
            UserDefaults.standard.setValue(selectedBookmark, forKey: DocType.defaultSaveFile + "SelectedDocument")
        } else {
            UserDefaults.standard.setValue(nil, forKey: DocType.defaultSaveFile + "SelectedDocument")
        }
    }

    func load() {
        var toResave = false
        if let docs = UserDefaults.standard.array(forKey: DocType.defaultSaveFile + "DocumentList") {
            self.documents = []
            for d in docs {
                do {
                    self.documents.append(try URL(resolvingBookmarkData: d as! Data, bookmarkDataIsStale: &toResave))
                    print("loaded documents")
                } catch { }
            }
        }
        
        if let selected = UserDefaults.standard.data(forKey: DocType.defaultSaveFile + "SelectedDocument") {
            do {
                self.documentPath = try URL(resolvingBookmarkData: selected, bookmarkDataIsStale: &toResave)
            } catch { self.documentPath = nil }
        }
        trim()
        findNewTemplate()
        save()
    }
}

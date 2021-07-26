//
//  CharSetDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/20/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let charSetDocument = UTType(exportedAs: "org.davidlong.tthcharset")
}

struct CharSetDocument: FileDocument, HandwritingDocument {
    var object: CharSet
    
    static func createNew(path: URL) {
        do {
            let data = try JSONEncoder().encode(CharSetDocument().object)
            try data.write(to: path)
        } catch {}
    }
    
    typealias ObjectType = CharSet
    
    static var defaultSaveFile = "charsets.json"
    static var fileExtension = ".tthcharset"
    static var fileType = UTType.charSetDocument
    
    init(from: Data) {
        object = try! JSONDecoder().decode(CharSet.self, from: from)
    }

    init(characters: Dictionary<String,Array<Data>> = [:], charlens: Dictionary<String,Float> = [:]) {
        object = CharSet(characters: characters, charlens: charlens)
    }

    static var readableContentTypes: [UTType] { [.charSetDocument] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        object = try JSONDecoder().decode(CharSet.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(object)
        return .init(regularFileWithContents: data)
    }
}

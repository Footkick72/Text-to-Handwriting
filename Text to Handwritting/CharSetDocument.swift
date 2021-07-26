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
    var charset: CharSet
    static var defaultSaveFile = "charsets.json"
    
    init(from: Data) {
        charset = try! JSONDecoder().decode(CharSet.self, from: from)
    }

    init(characters: Dictionary<String,Array<Data>> = [:], charlens: Dictionary<String,Float> = [:]) {
        charset = CharSet(characters: characters, charlens: charlens)
    }

    static var readableContentTypes: [UTType] { [.charSetDocument] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        charset = try JSONDecoder().decode(CharSet.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(charset)
        return .init(regularFileWithContents: data)
    }
}

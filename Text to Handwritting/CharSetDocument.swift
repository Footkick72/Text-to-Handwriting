//
//  CharSetDocument.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/20/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let charSetDocument = UTType(exportedAs: "com.example.charset")
}

struct CharSetDocument: FileDocument {
    var charset: CharSet

    init(name: String = "Untitled", characters: Dictionary<String,Array<Data>> = [:]) {
        charset = CharSet(name: name, characters: characters)
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

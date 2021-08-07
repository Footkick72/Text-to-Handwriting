//
//  CharSetDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/20/21.
//

import SwiftUI
import UniformTypeIdentifiers
import PencilKit

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
    
    static var defaultSaveFile = "charsets"
    static var fileExtension = ".tthcharset"
    static var fileType = UTType.charSetDocument
    static var defaults: Dictionary<URL, CharSet> = [
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("default.tthcharset"):
            try! JSONDecoder().decode(CharSet.self, from: FileManager.default.contents(atPath: Bundle.main.resourceURL!.appendingPathComponent("DefaultCharset.tthcharset").path)!)]
    
    init(from: Data) {
        object = try! JSONDecoder().decode(CharSet.self, from: from)
    }

    init(characters: Dictionary<String,Array<PKDrawing>> = [:], letterSpacing: Int = 4) {
        object = CharSet(characters: characters, letterSpacing: letterSpacing)
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

//
//  TemplateDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/23/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let templateDocument = UTType(exportedAs: "org.davidlong.tthtemplate")
}

struct TemplateDocument: FileDocument, HandwritingDocument {
    
    var object: Template
    
    static func createNew(path: URL) {
        do {
            let data = try JSONEncoder().encode(TemplateDocument().object)
            try data.write(to: path)
        } catch {}
    }
    
    typealias ObjectType = Template
    
    static var defaultSaveFile = "templates.json"
    static var fileExtension = ".tthtemplate"
    
    init(from: Data) {
        object = try! JSONDecoder().decode(Template.self, from: from)
    }

    init(bg: UIImage = UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect = CGRect(x: 50, y: 50, width: 750, height: 1000), size: Float = 30) {
        object = Template(bg: bg, margins: margins, size: size)
    }

    static var readableContentTypes: [UTType] { [.templateDocument] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        object = try JSONDecoder().decode(Template.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(object)
        return .init(regularFileWithContents: data)
    }
}

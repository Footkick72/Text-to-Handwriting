//
//  TemplateDocument.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/23/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let templateDocument = UTType(exportedAs: "org.davidlong.tthtemplate")
}

struct TemplateDocument: FileDocument {
    var template: Template
    
    init(from: Data) {
        template = try! JSONDecoder().decode(Template.self, from: from)
    }

    init(bg: UIImage = UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect = CGRect(x: 50, y: 50, width: 750, height: 1000), size: Float = 30) {
        template = Template(bg: bg, margins: margins, size: size)
    }

    static var readableContentTypes: [UTType] { [.templateDocument] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        template = try JSONDecoder().decode(Template.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(template)
        return .init(regularFileWithContents: data)
    }
}

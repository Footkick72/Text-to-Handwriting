//
//  TemplateDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/23/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static let templateDocument = UTType(exportedAs: "org.davidlong.t2ht")
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
    
    static var defaultSaveFile = "templates"
    static var fileExtension = ".t2ht"
    static var fileType = UTType.templateDocument
    static var defaults: Dictionary<URL, Template> = [
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("blank.t2ht"):
            Template(bg: UIImage(imageLiteralResourceName: "blankPaper.png"), margins: CGRect(x: 150, y: 150, width: 2250, height: 3000), size: 1.0, spacing: 60, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen"),
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("transparent.t2ht"):
            Template(bg: UIImage(imageLiteralResourceName: "transparentPaper.png"), margins: CGRect(x: 150, y: 150, width: 2250, height: 3000), size: 1.0, spacing: 60, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen"),
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("lined.t2ht"):
            Template(bg: UIImage(imageLiteralResourceName: "linedPaper.png"), margins: CGRect(x: 360, y: 400, width: 1950, height: 2810), size: 1.0, spacing: 85.4, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen")]
    
    init(from: Data) throws {
        object = try JSONDecoder().decode(Template.self, from: from)
    }

    init(bg: UIImage = UIImage(imageLiteralResourceName: "blankPaper.png"), margins: CGRect = CGRect(x: 150, y: 150, width: 2250, height: 3000), size: Float = 1.0, spacing: Float = 60, textColor: Array<Float> = [0.0, 0.0, 0.0, 1.0], writingStyle: String =  "Pen") {
        object = Template(bg: bg, margins: margins, size: size, spacing: spacing, textColor: textColor, writingStyle: writingStyle)
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
        let wrapper = FileWrapper.init(regularFileWithContents: data)
        wrapper.fileAttributes[FileAttributeKey.extensionHidden.rawValue] = NSNumber(booleanLiteral: true)
        return wrapper
    }
}

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
    
    static var defaultSaveFile = "templates"
    static var fileExtension = ".tthtemplate"
    static var fileType = UTType.templateDocument
    static var defaults: Dictionary<URL, Template> = [
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("blank.tthtemplate"):
            Template(bg: UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect(x: 50, y: 50, width: 750, height: 1000), size: 30, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen"),
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("transparent.tthtemplate"):
            Template(bg: UIImage(imageLiteralResourceName: "transparentpaper.png"), margins: CGRect(x: 50, y: 50, width: 750, height: 1000), size: 30, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen"),
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("lined.tthtemplate"):
            Template(bg: UIImage(imageLiteralResourceName: "linedpaper.png"), margins: CGRect(x: 120, y: 110, width: 650, height: 980), size: 23.68, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen")]
    
    init(from: Data) {
        object = try! JSONDecoder().decode(Template.self, from: from)
    }

    init(bg: UIImage = UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect = CGRect(x: 50, y: 50, width: 750, height: 1000), size: Float = 30, textColor: Array<Float> = [0.0, 0.0, 0.0, 1.0], writingStyle: String =  "Pen") {
        object = Template(bg: bg, margins: margins, size: size, textColor: textColor, writingStyle: writingStyle)
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

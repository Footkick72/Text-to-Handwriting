//
//  Text_to_HandwritingDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Photos
import PencilKit

struct Text_to_HandwritingDocument: FileDocument {
    var text: String
    var corrupted: Bool = false

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.plainText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            text = ""
            corrupted = true
            return
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if corrupted { throw CocoaError(.fileWriteInapplicableStringEncoding)}
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    func createImage(charset: CharSet, template: Template, updateProgress: @escaping (Double, Bool, Bool) -> Void) {
        ImageGenerator(text: text, charset: charset, template: template, updateProgress: updateProgress).createImage()
    }
}

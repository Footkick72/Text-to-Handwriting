//
//  AutoDocumentCreator.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/28/21.
//

import Foundation
import SwiftUI
import PencilKit

// this is necessary because in the current swiftUI document group, the user cannot choose what filetype to create, so it always defaults to a text file and thus the user cannot create charsets/templates. As a workaround, we have a class that creates empty charsets/templates on launch if none exist.

let DocumentCreator = AutoDocumentCreator()

class AutoDocumentCreator {
    
    let files: Dictionary<String, Data> = ["EmptyCharacterSet.tthcharset": try! JSONEncoder().encode(CharSet(characters: Dictionary<String, Array<PKDrawing>>(), charlens: Dictionary<String, Float>())),
                                           "EmptyTemplate.tthtemplate": try! JSONEncoder().encode(Template(bg: UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect(x: 50, y: 50, width: 750, height: 1000), size: 30, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen")),
                                           "Instructions.txt": try! JSONEncoder().encode("This is a sample instructions document which I will write late")]
    
    func createDocuments() {
        for file in files.keys {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
            if !FileManager.default.fileExists(atPath: url.path) {
                let data = files[file]!
                try! data.write(to: url)
            }
        }
        
        for url in CharSetDocument.defaults.keys {
            let data = try! JSONEncoder().encode(CharSetDocument.defaults[url])
            try! data.write(to: url)
        }
        
        for url in TemplateDocument.defaults.keys {
            let data = try! JSONEncoder().encode(TemplateDocument.defaults[url])
            try! data.write(to: url)
        }
    }
}

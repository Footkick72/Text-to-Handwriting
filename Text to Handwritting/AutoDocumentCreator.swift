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
    
    let files: Dictionary<String, Data> = ["EmptyCharacterSet.tthcharset": try! JSONEncoder().encode(CharSet(characters: Dictionary<String, Array<PKDrawing>>(), charlens: Dictionary<String, Float>(), letterSpacing: 4)),
                                           "EmptyTemplate.tthtemplate": try! JSONEncoder().encode(Template(bg: UIImage(imageLiteralResourceName: "blankpaper.png"), margins: CGRect(x: 50, y: 50, width: 750, height: 1000), size: 30, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen")),
                                           "Instructions.txt": """
                                            Welcome to Text to Handwritting!

                                            This application converts typed text into images of handwritten text. To see it in action, tap the "Convert to Handwritting" button at the top right of this document, and then tap "Save to Photos". A handwritten version of this file will be added to your photos.

                                            The generator supports simple markup. To make a word appear *bold*, place a "*" on either end of it. You can also _underline_ or use ~strikethrough~.

                                            The generation can be customized using the menu that appears after tapping "Convert to Handwritting". There is a character set that gives the handwriting style, and a template that gives the paper style. Tap on them to select a different character set or template. There are two default templates, for lined and unlined paper, and one default character set. The import button is used to select a new character set or template file from your filesystem.

                                            An empty character set and a blank template are automatically created in your filesystem. If these are deleted or renamed, they will be recreated upon app launch. These files are provided for creating your own character sets or template. They can be imported into the generator and used as described above.

                                            The template editor allows you to select a background image from your photos. Then select where the text should be drawn on that image by dragging the center or corners of the red rectangle that appears. At the bottom there are options for text size, text color, and the type of writing tool.

                                            The character set editor allows you to enter your own handwriting samples. The colors in the main view represent the completeness of the character set. Characters highlighted in red have no samples and will appear as blank, yellow characters have between 1 and 4 samples, and green characters have at least 5 samples. The more samples provided, the more variety in the generated text. Tap a character to open the writing view.

                                            In the writing view, there is a canvas for writing in the center. The character to write is shown at the top. The buttons above the canvas save the drawing, go the previous character, go to the next character, or clear the canvas. Every time an image is saved, it will be added to the scrolling view of images. To delete an image, tap the the "x" button on the top right of its preview.
                                            """.data(using: .utf8)!]
    
    func createDocuments() {
        for file in files.keys {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
            if !FileManager.default.fileExists(atPath: url.path) {
                let data = files[file]!
                try! data.write(to: url)
            }
        }
        
        for url in CharSetDocument.defaults.keys {
            if !FileManager.default.fileExists(atPath: url.path) {
                let data = try! JSONEncoder().encode(CharSetDocument.defaults[url])
                try! data.write(to: url)
            }
        }
        
        for url in TemplateDocument.defaults.keys {
            if !FileManager.default.fileExists(atPath: url.path) {
                let data = try! JSONEncoder().encode(TemplateDocument.defaults[url])
                try! data.write(to: url)
            }
        }
    }
}

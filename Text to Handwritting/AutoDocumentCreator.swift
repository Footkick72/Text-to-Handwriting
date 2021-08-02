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

                                            This application is used to convert typed text into images of handwritten text. To see it in action, tap the "Convert to Handwritting" button at the top right of this document, and then tap "Save to Photos". A handwritten version of this file will be added to your photos.

                                            The generator supports a primitive form of markdown. To make a word appear *bold*, place a "*" on either end of it. You can also _underline_ or use ~strikethrough~.

                                            The generation process can be customized. To adjust it, use the menu that appears after tapping "Convert to Handwritting". There is a character set, which defines the shapes of the characters, and a template, which defines the background and placement of the text. These are both selected by default. Click on either to select a different character set or template. By default, there are two templates and one character set. The import button is used import a new character set or template file from your filesystem.

                                            By default, there is an empty character set and a blank template created in your filesystem. If these are deleted or renamed, they will be regenerated upon app launch. In the current IOS, it is impossible to create one of these files from the normal filesystem, so these files are provided for modification and as a basis for duplication should more be desired. They can be imported into the generator and used as described above.

                                            The template editor allows you to select a background image from your photos via the button at the top, and then select where the text should be drawn on that image by dragging the red rectangle appearing on top of the image around. The drawing area can be resized by tapping and dragging a corner. At the bottom, there are options for font size, visually displayed within the drawing area on the image, font color, and writing tool.

                                            The character set editor allows you to enter your own handwriting samples for the generator to use. The main view is color-coded to represent the completeness of the character set. Characters highlighted in red have no provided samples, yellow characters have between 1 and 4 samples, and green characters have at least 5 samples. The more samples provided, the more variety in the generated text, though it is possible to provide only one sample per character, or even none, which will result in a blank space where the character would have been. Tap any one of the characters in the view to open the writing view, where there is a canvas for writing. Near the top, the character to write is displayed. The buttons above the canvas save the drawing, go the previous character, go to the next character, or clear the canvas, from left to right respectively. Every time an image is saved, it will be displayed in a scrolling view of all previously defined images of that character. To delete a previously created image, tap the the "x" button on the top right of its preview.
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
            let data = try! JSONEncoder().encode(CharSetDocument.defaults[url])
            try! data.write(to: url)
        }
        
        for url in TemplateDocument.defaults.keys {
            let data = try! JSONEncoder().encode(TemplateDocument.defaults[url])
            try! data.write(to: url)
        }
    }
}

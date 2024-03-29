//
//  AutoDocumentCreator.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/28/21.
//

import Foundation
import SwiftUI
import PencilKit

// this is necessary because in the current swiftUI document group, the user cannot choose what filetype to create, so it always defaults to a text file and thus the user cannot create charsets/templates. As a workaround, we have a class that creates empty charsets/templates on launch if none exist.

let DocumentCreator = AutoDocumentCreator()

class AutoDocumentCreator {
    
    let files: Dictionary<String, Data> = ["EmptyCharacterSet.t2hc": try! JSONEncoder().encode(CharSet(characters: Dictionary<String, Array<PKDrawing>>(), letterSpacing: 4)),
                                           "EmptyTemplate.t2ht": try! JSONEncoder().encode(Template(bg: UIImage(imageLiteralResourceName: "blankPaper.png"), margins: CGRect(x: 0, y: 0, width: 2550, height: 3300), size: 1.0, spacing: 60, textColor: [0.0, 0.0, 0.0, 1.0], writingStyle: "Pen"))]
    
    let instructions = """
                                            Welcome to Text to Handwriting!
                                            
                                                This application converts typed text into images of handwritten text. To see it in action, tap the "Handwrite" button at the top right of this document, and then tap "Save to photos". A handwritten version of this file will be added to your photos.
                                            
                                                The generation can be customized when tapping "Handwrite". There is a character set that gives the handwriting style, and a template that gives the paper style. Tap on them to select a different character set or template. There are default templates for lined and unlined paper, and one default character set. The import button is used to select a new character set or template file from your filesystem. The generator supports simple markdown. You can place a pair of "*"s on either end of **any text you want to bold**. You can also __underline text__ with two "_"s or use two "~"s for ~~strikethrough~~. You can also combine these modifiers together to create **~~__an effect like this.__~~**
                                            
                                                An empty character set and a blank template are automatically created in your filesystem. If these are deleted or renamed, they will be recreated upon app launch. These files are provided for creating your own character sets or templates. They can be customized and then used as described above.
                                            
                                                The template editor allows you to select a background image from your photos. Select where the text should be drawn on that image by dragging the center or corners of the red rectangle that appears. At the bottom there are options for text size, line spacing, text color, and the type of writing tool.
                                            
                                                The character set editor allows you to create your own handwriting samples. To add new characters, press the blue plus button located at the bottom of the set and select the desired characters from a list of preset options, including common languages. However, keep in mind that the presets are not exhaustive, so you may need to use the "paste text" button to add characters by pasting a sample of text. The editor supports any unicode characters, including other languages, mathematical symbols, and emojis. The colors in the main view indicate the completeness of the set: characters highlighted in red have no samples, yellow characters have 1-4 samples, and green characters have at least 5 samples. The more samples provided, the more variations in the generated text. To edit a character, tap on it to open the writing view. There are two ways to adjust the thickness of the characters: a "character thickness" slider located at the top of the editor which affects all characters, and character-by-character editing using the "thicken" and "un-thicken" buttons located at the top which appear when selecting. By pressing "select" at the top right, you can select multiple characters by tapping or swiping. Selecting also reveals buttons at the top that delete or copy the selected characters. If you have copied any characters, a "paste" button will appear, allowing you to move handwriting samples between character sets.
                                            
                                                In the writing view, there is a canvas for writing in the center. The character to write is shown at the top. The buttons above the canvas save the drawing, go the previous character, go to the next character, or clear the canvas. Every time an image is saved, it will be added to the scrolling view of images. To delete an image, tap the the "x" button on the top right of its preview.
                                            """.data(using: .utf8)!
    
    func createDocuments() {
        for (path, file) in files {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(path)
            if !FileManager.default.fileExists(atPath: url.path) {
                try! file.write(to: url)
            }
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Instructions.txt")
        try! instructions.write(to: url)
        
        for (url, file) in CharSetDocument.defaults {
            let data = try! JSONEncoder().encode(file)
            try! data.write(to: url)
        }
        
        for (url, file) in TemplateDocument.defaults {
            let data = try! JSONEncoder().encode(file)
            try! data.write(to: url)
        }
    }
}

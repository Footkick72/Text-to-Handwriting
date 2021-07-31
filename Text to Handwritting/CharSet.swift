//
//  CharSet.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import SwiftUI
import PencilKit

struct CharSet: Equatable, Codable, HandwritingDocumentResource {
    var availiable_chars: String
    var characters: Dictionary<String,Array<PKDrawing>>
    var charlens: Dictionary<String,Float> = [:]
    var letterSpacing: Int
    
    init(characters: Dictionary<String,Array<PKDrawing>>, charlens: Dictionary<String,Float>? = nil, letterSpacing: Int = 4) {
        self.characters = characters
        self.availiable_chars = ""
        self.letterSpacing = letterSpacing
        for char in characters.keys {
            availiable_chars += char
        }
        if charlens == nil {
            self.charlens = self.getCharlens()!
        } else {
            self.charlens = charlens!
        }
    }
    
    func numberOfCharacters(char: String) -> Int {
        return self.getImages(char: char).count
    }
    
    func getImage(char: String) -> PKDrawing? {
        let images = getImages(char: char)
        if images.count > 0 {
            return images.randomElement()!
        } else {
            return nil
        }
    }
    
    func getSameImage(char: String) -> PKDrawing {
        // returns the same image always for UI display purposes
        let images = getImages(char: char)
        if images.count > 0 {
            return images.first!
        } else {
            return PKDrawing()
        }
    }
    
    func getImages(char: String) -> Array<PKDrawing> {
        guard let data = self.characters[char] else {
            return Array<PKDrawing>()
        }
        return data
    }
    
    func getCharlens() -> Dictionary<String,Float>? {
        //multiply by Float(font_size), add letter_spacing * Float(font_size) / 256 to convert to accurate sizes upon generation
        var lengths: Dictionary<String,Float> = [:]
        for char in availiable_chars {
            lengths[String(char)] = self.getCharlen(char: char)
        }
        return lengths
    }
    
    func getCharlen(char: Character) -> Float {
        var charlen: Float = 0
        let images = getImages(char: String(char))
        for file in images {
            charlen += Float(file.bounds.width)
        }
        return charlen/Float(images.count)
    }
    
    func getPreview() -> UIImage {
        if availiable_chars.count == 0 {
            return UIImage(cgImage: UIImage(named: "space")!.cgImage!, scale: 4.0, orientation: .up)
        }
        var image = PKDrawing()
        var i = 0
        for y in 0..<3 {
            for x in 0..<3 {
                var char = getSameImage(char: String(availiable_chars[i]))
                char.transform(using: CGAffineTransform(translationX: CGFloat(x*256), y: CGFloat(y*256)))
                image.append(char)
                i += 1
                if i >= availiable_chars.count {
                    return image.image(from: CGRect(x: 0, y: 0, width: 256*3, height: 256*3), scale: 5.0)
                }
            }
        }
        return image.image(from: CGRect(x: 0, y: 0, width: 256*3, height: 256*3), scale: 5.0)
    }
    
    func isCompleteFor(text: String) -> Bool {
        for char in text {
            if numberOfCharacters(char: String(char)) == 0 && char != " " && char != "\n"{
                return false
            }
        }
        return true
    }
}

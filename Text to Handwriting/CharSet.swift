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
    var available_chars: String
    var characters: Dictionary<String,Array<PKDrawing>>
    var letterSpacing: Int
    var forceMultiplier: Float
    
    init(characters: Dictionary<String,Array<PKDrawing>>, letterSpacing: Int = 4, forceMultiplier: Float = 1) {
        self.characters = characters
        self.available_chars = ""
        self.letterSpacing = letterSpacing
        self.forceMultiplier = forceMultiplier
        for char in characters.keys {
            available_chars += char
        }
    }
    
    mutating func addChars(chars: String) {
        for c in chars {
            if !available_chars.contains(c) && !c.isWhitespace {
                available_chars.append(c)
            }
            available_chars = String(available_chars.sorted())
        }
    }
    
    mutating func removeChars(chars: String) {
        for c in chars {
            if available_chars.contains(c) {
                available_chars.remove(at: available_chars.firstIndex(of: c)!)
                characters.removeValue(forKey: String(c))
            }
        }
    }
    
    func numberOfCharacters(char: String) -> Int {
        return self.getDrawings(char: char).count
    }
    
    func getDrawWidth(forSize: CGFloat) -> CGFloat {
        var sum: CGFloat = 0
        for char in available_chars {
            let image = getDrawing(char: String(char))!
            var strokeSum = 0
            for stroke in image.strokes {
                var pathSum = 0
                stroke.path.forEach({ point in
                    pathSum += Int(point.size.width + point.size.height)
                })
                pathSum /= stroke.path.count * 2
                strokeSum += pathSum
            }
            strokeSum /= image.strokes.count
            sum += CGFloat(strokeSum)
        }
        let width: CGFloat = sum/CGFloat(available_chars.count) * sqrt(CGFloat(forSize/256.0)) * 2.2
        return width
    }
    
    func getDrawing(char: String) -> PKDrawing? {
        let images = getDrawings(char: char)
        return images.randomElement()
    }
    
    func getSameDrawing(char: String) -> PKDrawing {
        // returns the same image always for UI display purposes
        let images = getDrawings(char: char)
        if images.count > 0 {
            return images.first!
        } else {
            return PKDrawing()
        }
    }
    
    func getSameImage(char: String) -> UIImage {
        let drawing = getSameDrawing(char: char)
        return drawing.image(from: CGRect(x: 0, y: 0, width: 256, height: 256), scale: 1.0)
    }
    
    func getDrawings(char: String) -> Array<PKDrawing> {
        guard let data = self.characters[char] else {
            return Array<PKDrawing>()
        }
        return data
    }
    
    func getPreview() -> UIImage {
        if available_chars.count == 0 {
            return UIImage(cgImage: UIImage(named: "space")!.cgImage!, scale: 4.0, orientation: .up)
        }
        var image = PKDrawing()
        var i = 0
        for y in 0..<3 {
            for x in 0..<3 {
                var char = getSameDrawing(char: String(available_chars[i]))
                char.transform(using: CGAffineTransform(translationX: CGFloat(x*256), y: CGFloat(y*256)))
                image.append(char)
                i += 1
                if i >= available_chars.count {
                    return image.image(from: CGRect(x: 0, y: 0, width: 256*3, height: 256*3), scale: 5.0)
                }
            }
        }
        return image.image(from: CGRect(x: 0, y: 0, width: 256*3, height: 256*3), scale: 5.0)
    }
    
    func isCompleteFor(text: String) -> Bool {
        for char in text {
            // do we have it? is it a whitespace or a markdown character? No to both = return false
            if numberOfCharacters(char: String(char)) == 0 && "\t \n*_~…".firstIndex(of: char) == nil {
                return false
            }
        }
        return true
    }
}

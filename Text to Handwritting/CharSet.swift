//
//  CharSet.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import UIKit

struct CharSet: Equatable, Codable, HandwritingDocumentResource {
    var availiable_chars: String
    var characters: Dictionary<String,Array<Data>>
    var charlens: Dictionary<String,Float> = [:]
    
    init(characters: Dictionary<String,Array<Data>>, charlens: Dictionary<String,Float>? = nil) {
        self.characters = characters
        self.availiable_chars = ""
        for char in characters.keys {
            availiable_chars += char
        }
        if charlens == nil {
            self.charlens = self.get_charlens()!
        } else {
            self.charlens = charlens!
        }
    }
    
    func numberOfCharacters(char: String) -> Int {
        return self.getImages(char: char).count
    }
    
    func getImage(char: String) -> UIImage? {
        let images = getImages(char: char)
        if images.count > 0 {
            return images.randomElement()!
        } else {
            return nil
        }
    }
    
    func getSameImage(char: String) -> UIImage {
        // returns the same image always for UI display purposes
        let images = getImages(char: char)
        if images.count > 0 {
            return images.first!
        } else {
            return UIImage(named: "space")!
        }
    }
    
    func getImages(char: String) -> Array<UIImage> {
        guard let data = self.characters[char] else {
            return Array<UIImage>()
        }
        var images: Array<UIImage> = []
        for datum in data {
            images.append(UIImage(data: datum)!)
        }
        return images
    }
    
    func get_charlens() -> Dictionary<String,Float>? {
        //multiply by Float(font_size), add letter_spacing * Float(font_size) / 256 to convert to accurate sizes upon generation
        var lengths: Dictionary<String,Float> = [:]
        for char in availiable_chars {
            lengths[String(char)] = self.get_charlen(char: char)
        }
        return lengths
    }
    
    func get_charlen(char: Character) -> Float {
        var charlen: Float = 0
        let images = getImages(char: String(char))
        for file in images {
            let box = file.cropAlpha(cropVertical: true, cropHorizontal: true).size
            let scaler: Float = 1.0/Float(file.size.width)
            charlen += Float(box.width) * scaler
        }
        return charlen/Float(images.count)
    }
    
    func getPreview() -> UIImage {
        if availiable_chars.count == 0 {
            return UIImage(cgImage: UIImage(named: "space")!.cgImage!, scale: 4.0, orientation: .up)
        }
        UIGraphicsBeginImageContext(CGSize(width: 256*3, height: 256*3))
        var i = 0
        for y in 0..<3 {
            for x in 0..<3 {
                var char = getSameImage(char: String(availiable_chars[i]))
                char = UIImage(cgImage: char.cgImage!, scale: 1.0, orientation: char.imageOrientation)
                let rect = CGRect(x: x*256, y: y*256, width: 256, height: 256)
                char.draw(in: rect, blendMode: .normal, alpha: 1.0)
                i += 1
                if i >= availiable_chars.count {
                    let image = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    return image
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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

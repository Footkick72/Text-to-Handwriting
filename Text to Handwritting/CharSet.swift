//
//  CharSet.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import UIKit

class CharSet: Codable {
    var name: String
    var availiable_chars: String
    var characters: Dictionary<String,Array<Data>>
    var charlens: Dictionary<String,Float> = [:]
    
    init(name: String, characters: Dictionary<String,Array<Data>>, charlens: Dictionary<String,Float>? = nil) {
        self.name = name
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
    
    func has_character(char: String) -> Bool {
        return (self.availiable_chars.firstIndex(of: Character(char)) != nil)
    }
    
    func add_characters(char: String, images: Array<UIImage>) {
        if images.count == 0 {
            return
        }
        self.availiable_chars += char
        var data = Array<Data>()
        for i in images {
            data.append(i.pngData()!)
        }
        self.characters[char] = data
        self.charlens[char] = get_charlen(char: Character(char))
    }
    
    func getImage(char: String) -> UIImage {
        let images = getImages(char: char)
        if images.count > 0 {
            return images.randomElement()!
        } else {
            return UIImage(imageLiteralResourceName: "space.png")
        }
    }
    
    func getSameImage(char: String) -> UIImage {
        // returns the same image always for UI display purposes
        let images = getImages(char: char)
        if images.count > 0 {
            return images.first!
        } else {
            return UIImage(imageLiteralResourceName: "space.png")
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
    
    func get_json_data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return data
    }
}

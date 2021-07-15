//
//  CharSet.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import UIKit

struct CharSet: Codable {
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
    
    func getImage(char: String) -> UIImage {
        let images = getImages(char: char)
        if images.count > 0 {
            return images.randomElement()!
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
            var charlen: Float = 0
            let images: Array<UIImage>
            images = getImages(char: String(char))
            for file in images {
                let box = file.cropAlpha(cropVertical: true, cropHorizontal: true).size
                let scaler: Float = 1.0/Float(file.size.width)
                charlen += Float(box.width) * scaler
            }
            lengths[String(char)] = charlen/Float(images.count)
        }
        return lengths
    }
    
    func get_json_data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return data
    }
}

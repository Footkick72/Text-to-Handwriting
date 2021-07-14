//
//  CharSet.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import UIKit

struct CharSet {
    var name: String
    var availiable_chars: String
    var substitutions: Dictionary<String,String>
    var charlens: Dictionary<String,Float> = [:]
    
    init(name: String = "Unnamed character set") {
        self.name = name
        self.availiable_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz’‘':,![(.?])\"”;"
        self.substitutions = ["A":"aa",
                              "B":"bb",
                              "C":"cc",
                              "D":"dd",
                              "E":"ee",
                              "F":"ff",
                              "G":"gg",
                              "H":"hh",
                              "I":"ii",
                              "J":"jj",
                              "K":"kk",
                              "L":"ll",
                              "M":"mm",
                              "N":"nn",
                              "O":"oo",
                              "P":"pp",
                              "Q":"qq",
                              "R":"rr",
                              "S":"ss",
                              "T":"tt",
                              "U":"uu",
                              "V":"vv",
                              "W":"ww",
                              "X":"xx",
                              "Y":"yy",
                              "Z":"zz",
                              "’":"apostrophe",
                              "‘":"apostrophe",
                              "'":"apostrophe",
                              ":":"colon",
                              ",":"comma",
                              "!":"exmark",
                              "[":"lbracket",
                              "(":"lparentheses",
                              ".":"period",
                              "?":"qmark",
                              "]":"rbracket",
                              ")":"rparentheses",
                              "\"":"qoute",
                              "”":"qoute",
                              ";":"semicolon"]
        self.charlens = self.get_charlens()!
    }
    
    func getImage(char: String) throws -> UIImage? {
        return try getImages(char: char)!.randomElement()
    }
    
    func getImages(char: String) throws -> Array<UIImage>? {
        var charcode = char
        if let alternate = self.substitutions[char] {
            charcode = alternate
        }
        let path = Bundle.main.resourcePath! + "/" + self.name + "/" + charcode
        let items = try FileManager.default.contentsOfDirectory(atPath: path)
        return items.map { UIImage(contentsOfFile: path + "/" + $0)! }
    }
    
    func get_charlens() -> Dictionary<String,Float>? {
        //multiply by Float(font_size), add letter_spacing * Float(font_size) / 256 to convert to accurate sizes
        var lengths: Dictionary<String,Float> = [:]
        for char in availiable_chars {
            var charlen: Float = 0
            let images: Array<UIImage>
            do {
                images = try getImages(char: String(char))!
            } catch {
                print("Charset failed to return image on character " + String(char) + " during charlens calculation, aborting...")
                return nil
            }
            for file in images {
                let box = file.cropAlpha(cropVertical: true, cropHorizontal: true).size
                let scaler: Float = 1.0/Float(file.size.width)
                charlen += Float(box.width) * scaler
            }
            lengths[String(char)] = charlen/Float(images.count)
        }
        return lengths
    }
}

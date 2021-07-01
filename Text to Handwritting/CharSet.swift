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
}

//
//  CharSetCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation
import SwiftUI

var CharSets = CharSetCatalog()

class CharSetCatalog: ObservableObject {
    @Published var primary_set: String
    @Published var sets: Dictionary<String,CharSet>
    
    init() {
        self.primary_set = ""
        self.sets = Dictionary()
        self.load_sets()
        if (self.sets.keys.firstIndex(of: "default") == nil) {
            
            let availiable_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz’‘':,![(.?])\"”;"
            let substitutions = ["A":"aa",
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
            
            var charlist: Dictionary<String,Array<Data>> = [:]
            
            for char in availiable_chars {
                var charcode: String = String(char)
                if substitutions[String(char)] != nil {
                    charcode = String(substitutions[String(char)]!)
                }
                
                var images: Array<Data> = []
                do {
                    for imagedir in try FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath! + "/letters/" + charcode + "/") {
                        let imageData = UIImage(contentsOfFile: Bundle.main.resourcePath! + "/letters/" + charcode + "/" + imagedir)?.pngData()
                        images.append(imageData!)
                    }
                } catch { print("error loading character '" + String(char) + "' of default charset: "); print(error) }
                
                charlist[String(char)] = images
            }
            self.sets["default"] = CharSet(name:"default", characters: charlist)
            self.save_sets()
        }
        self.primary_set = self.sets.first!.key
    }
    
    func get_set() -> CharSet{
        return sets[primary_set]!
    }
    
    func save_sets() {
        let manager = FilesManager()
        do { try manager.save(fileNamed: "charsets.txt", data: sets.values.map({$0.name}).joined(separator: " ").data(using: .utf8)!) } catch {
            print("Failed to save charsets.txt: ")
            print(error)
        }
        for k in self.sets.keys {
            let set = self.sets[k]
            do {
                try manager.save(fileNamed: set!.name + ".charset", data: set!.get_json_data())
            } catch { print(set!.name + " failed to save, continuing..."); continue }
        }
    }
    
    func load_sets() {
        let manager = FilesManager()
        do {
            for name in String(data: try manager.read(fileNamed: "charsets.txt"), encoding: .utf8)!.split(separator: " ") {
                let data = try manager.read(fileNamed: name + ".charset")
                let decoder = JSONDecoder()
                let charset = try decoder.decode(CharSet.self, from: data)
                self.sets[charset.name] = charset
            }
        } catch {
            print("Error loading charsets: ")
            print(error)
        }
    }
}

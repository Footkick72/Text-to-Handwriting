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
    @Published var primarySet: String
    @Published var sets: Dictionary<String,CharSet>
    
    init() {
        self.primarySet = ""
        self.sets = Dictionary()
        self.loadSets()
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
            self.saveSets()
        }
        self.primarySet = self.sets.first!.key
    }
    
    func getSet() -> CharSet {
        return sets[primarySet]!
    }
    
//    func add_characters_to_set(char: String, images: Array<UIImage>) {
//        objectWillChange.send()
//        getSet().add_characters(char: char, images: images)
//    }
    
    func selectSet(name: String) {
        for key in self.sets.keys {
            if self.sets[key]!.name == name {
                self.primarySet = key
                return
            }
        }
    }
    
    func createSet() {
        var i = 0
        while self.sets.keys.firstIndex(of: "Untitled" + String(i)) != nil {
            i += 1
        }
        let name = "Untitled" + String(i)
        self.sets[name] = CharSet(name: name, characters: Dictionary<String, Array<Data>>())
        self.primarySet = name
    }
    
    func deleteSet() {
        self.sets.removeValue(forKey: self.primarySet)
        self.primarySet = self.sets.keys.first!
    }
    
//    func renameSet(name: String) {
//        objectWillChange.send()
//        getSet().name = name
//    }
    
    func saveSets() {
        let manager = FilesManager()
        do {
            for name in String(data: try manager.read(fileNamed: "charsets.txt"), encoding: .utf8)!.split(separator: " ") {
                if sets.values.map({$0.name}).firstIndex(of: String(name)) == nil {
                    try manager.delete(fileNamed: name + ".charset")
                }
            }
        } catch {
            print("Failed to delete old charsets: ")
            print(error)
        }
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
    
    func loadSets() {
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

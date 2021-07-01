//
//  CharSetCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import Foundation

var CharSets = CharSetCatalog()

struct CharSetCatalog {
    var primary_set: String
    var sets: Dictionary<String,CharSet>
    
    init() {
        self.primary_set = "default"
        self.sets = ["default": CharSet(name:"letters")]
    }
    
    func get_set() -> CharSet{
        return sets[primary_set]!
    }
}

//
//  TemplateCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation

var Templates = TemplateCatalog()

struct TemplateCatalog {
    var primary_template: String
    var templates: Dictionary<String,Template>
    
    init() {
        self.primary_template = "lined"
        self.templates = ["lined": Template(bg: "linedpaper.png",
                                            margins: [40,20,100,160],
                                            size: 28,
                                            line_spacing: 27,
                                            letter_spacing: 4,
                                            space_length: 16,
                                            line_end_buffer: 25),
                          "blank": Template(bg: "blankpaper.png",
                                                 margins: [50,50,50,50],
                                                 size: 28,
                                                 line_spacing: 27,
                                                 letter_spacing: 4,
                                                 space_length: 16,
                                                 line_end_buffer: 25)]
    }
    
    func get_template() -> Template{
        return templates[primary_template]!
    }
}

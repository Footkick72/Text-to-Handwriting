//
//  TemplateCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

var Templates = TemplateCatalog()

struct TemplateCatalog {
    var primary_template: String
    var templates: Dictionary<String,Template>
    
    init() {
        self.primary_template = "lined"
        self.templates = ["lined": Template(bg: "linedpaper.png",
                                            margins: [40,20,100,160],
                                            size: 28),
                          "blank": Template(bg: "blankpaper.png",
                                            margins: [50,50,50,50],
                                            size: 28)]
    }
    
    func get_template() -> Template{
        return templates[primary_template]!
    }
    
    mutating func create_template(name: String, image: UIImage, margins: Array<Int>, font_size: Int) {
        let imageName = name + "paper.png"
        let imagePath = Bundle.main.resourcePath! + "/" + imageName
        FileManager.default.createFile(atPath: imagePath, contents: image.pngData(), attributes: nil)
        self.templates[name] = Template(bg: imageName,
                                        margins: margins,
                                        size: font_size)
    }
}

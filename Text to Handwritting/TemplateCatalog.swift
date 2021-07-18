//
//  TemplateCatalog.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

var Templates = TemplateCatalog()

class TemplateCatalog: ObservableObject {
    @Published var primaryTemplate: String
    @Published var templates: Dictionary<String,Template>
    
    let savePath = Bundle.main.resourcePath! + "/Templates/"
    
    init() {
        self.primaryTemplate = ""
        self.templates = Dictionary()
        self.loadTemplates()
        if (self.templates.keys.firstIndex(of: "lined") == nil) {
            self.createTemplate(name: "lined",
                                image: UIImage(imageLiteralResourceName: "linedpaper.png"),
                                margins: [40,20,100,160],
                                fontSize: 28)
        }
        if (self.templates.keys.firstIndex(of: "blank") == nil) {
            self.createTemplate(name: "blank",
                                image: UIImage(imageLiteralResourceName: "blankpaper.png"),
                                margins: [50,50,50,50],
                                fontSize: 28)
        }
        self.primaryTemplate = self.templates.first!.key
    }
    
    func get_template() -> Template{
        return templates[primaryTemplate]!
    }
    
    func createTemplate(name: String, image: UIImage, margins: Array<Int>, fontSize: Int) {
        self.templates[name] = Template(name: name,
                                        bg: image,
                                        margins: margins,
                                        size: fontSize)
    }
    
    func deleteTemplate() {
        self.templates.removeValue(forKey: self.primaryTemplate)
        self.primaryTemplate = self.templates.keys.first!
    }
    
    func editTemplate(originalName: String, name: String, image: UIImage, margins: Array<Int>, fontSize: Int) {
        self.templates.removeValue(forKey: originalName)
        self.createTemplate(name: name, image: image, margins: margins, fontSize: fontSize)
    }
    
    func saveTemplates() {
        let manager = FilesManager()
        do {
            for name in String(data: try manager.read(fileNamed: "templates.txt"), encoding: .utf8)!.split(separator: " ") {
                if templates.values.map({$0.name}).firstIndex(of: String(name)) == nil {
                    try manager.delete(fileNamed: name + ".template")
                }
            }
        } catch {
            print("Failed to delete old templates: ")
            print(error)
        }
        do { try manager.save(fileNamed: "templates.txt", data: templates.values.map({$0.name}).joined(separator: " ").data(using: .utf8)!) } catch {
            print("Failed to save templates.txt: ")
            print(error)
        }
        for k in self.templates.keys {
            let template = self.templates[k]
            do {
                try manager.save(fileNamed: template!.name + ".template", data: template!.get_json_data())
            } catch { print(template!.name + " failed to save, continuing..."); continue }
        }
    }
    
    func loadTemplates() {
        let manager = FilesManager()
        do {
            for name in String(data: try manager.read(fileNamed: "templates.txt"), encoding: .utf8)!.split(separator: " ") {
                let data = try manager.read(fileNamed: name + ".template")
                let decoder = JSONDecoder()
                let template = try decoder.decode(Template.self, from: data)
                self.templates[template.name] = template
            }
        } catch {
            print("Error loading templates: ")
            print(error)
        }
    }
}

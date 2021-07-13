//
//  Template.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

struct Template: Codable {
    let background: Data
    let margins: Array<Int>
    let font_size: Int
    let name: String
    
    init(name: String, bg: UIImage, margins: Array<Int>, size: Int) {
        self.background = bg.pngData()!
        self.margins = margins
        self.font_size = size
        self.name = name
    }
    
    func get_bg() -> UIImage {
        return UIImage(data: background)!
    }
    
    func get_margin_rect() -> CGRect {
        return CGRect(x: margins[0],
                      y: margins[2],
                      width: Int(get_bg().size.width) - margins[1] - margins[0],
                      height: Int(get_bg().size.height) - margins[3] - margins[2])
        
    }
    
    func get_json_data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return data
    }
}

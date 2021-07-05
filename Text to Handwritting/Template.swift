//
//  Template.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import UIKit

struct Template {
    let background: String
    let margins: Array<Int>
    let font_size: Int
    let line_spacing: Int
    let letter_spacing: Int
    let space_length: Int
    let line_end_buffer: Int
    
    init(bg: String, margins: Array<Int>, size: Int, line_spacing: Int, letter_spacing: Int, space_length: Int, line_end_buffer: Int) {
        self.background = bg
        self.margins = margins
        self.font_size = size
        self.line_spacing = line_spacing
        self.letter_spacing = letter_spacing
        self.space_length = space_length
        self.line_end_buffer = line_end_buffer
    }
    
    func get_bg() -> UIImage {
        return UIImage(contentsOfFile: Bundle.main.resourcePath! + "/" + background)!
    }
}

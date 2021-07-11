//
//  Template.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

struct Template {
    let background: String
    let margins: Array<Int>
    let font_size: Int
    
    init(bg: String, margins: Array<Int>, size: Int) {
        self.background = bg
        self.margins = margins
        self.font_size = size
    }
    
    func get_bg() -> UIImage {
        return UIImage(contentsOfFile: Bundle.main.resourcePath! + "/" + background)!
    }
}

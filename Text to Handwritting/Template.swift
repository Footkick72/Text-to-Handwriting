//
//  Template.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/3/21.
//

import Foundation
import SwiftUI

struct Template: Equatable, Codable, HandwritingDocumentResource {
    var background: Data
    var margins: CGRect
    var font_size: Float
    
    init(bg: UIImage, margins: CGRect, size: Float) {
        self.background = bg.pngData()!
        self.margins = margins
        self.font_size = size
    }
    
    func getBackground() -> UIImage {
        return UIImage(data: background)!
    }
    
    func getMargins() -> Array<Int> {
        return [margins.minX, getBackground().size.width - margins.maxX, margins.minY, getBackground().size.height - margins.maxY].map { Int($0) }
    }
    
    func getPreview() -> UIImage {
        return getBackground()
    }
    
    func isCompleteFor(text: String) -> Bool {
        return true
    }
}

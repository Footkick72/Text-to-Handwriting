//
//  TemplateEditor.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct TemplateEditor: View {
    @Binding var document: TemplateDocument
//    @State var selected_image = Templates.get_template().get_bg() as UIImage?
//    @State var image_draw_rect = Templates.get_template().get_margin_rect()
//    @State var image_draw_rect_scaled: CGRect? = nil
//    @State var font_size: Float = Float(Templates.get_template().font_size)
//    @Binding var shown: templateViews?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ImageRectSelector(document: $document)
            NumberSelector(value: $document.template.font_size, minValue: 5, maxValue: 200, label: "Font size")
                .frame(width: 300)
        }
    }

//    func save_template() {
//        let margins = [Int(image_draw_rect_scaled!.minX),
//                       Int(selected_image!.size.width - image_draw_rect_scaled!.maxX),
//                       Int(image_draw_rect_scaled!.minY),
//                       Int(selected_image!.size.height - image_draw_rect_scaled!.maxY)]
//        Templates.editTemplate(originalName: originalName,
//                                name: templateName,
//                                image: selected_image!,
//                                margins: margins,
//                                fontSize: Int(font_size))
//    }
}

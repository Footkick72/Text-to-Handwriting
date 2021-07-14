//
//  TemplateEditor.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct TemplateEditor: View {
    @State var selected_image = Templates.get_template().get_bg() as UIImage?
    @State var image_draw_rect = Templates.get_template().get_margin_rect()
    @State var image_draw_rect_scaled: CGRect? = nil
    @State var font_size: Float = Float(Templates.get_template().font_size)
    @State var showingSaveDialog = false
    @State var templateName = Templates.get_template().name
    @State var originalName = Templates.get_template().name
    @Binding var shown: templateViews?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Edit Template")
            TextField("Template Name", text: $templateName)
                .frame(width: 200)
                .multilineTextAlignment(.center)
                .autocapitalization(.none)
            ImageOptionsDisplay(image: $selected_image, rect: $image_draw_rect, real_rect: $image_draw_rect_scaled, font_size: $font_size)
            NumberSelector(value: $font_size, minValue: 5, maxValue: 200, label: "Font size")
                .frame(width: 300)
            Button("Save Changes") {
                showingSaveDialog = true
            }
            .foregroundColor(.green)
            Button("Cancel") {
                shown = nil
            }
            .foregroundColor(.red)
        }
        .alert(isPresented: $showingSaveDialog) {
            if templateName == "" {
                return Alert(title: Text("Save"), message: Text("Cannot save, name the template first"), dismissButton: .cancel())
            }
            else {
                return Alert(title: Text("Save"),
                      message: Text("Are you sure you want to save changes to template " + templateName + "?"),
                      primaryButton: .default(Text("Save")) {
                        self.save_template()
                        shown = nil
                      },
                      secondaryButton: .cancel()
                )
            }
        }
    }
    
    func save_template() {
        let margins = [Int(image_draw_rect_scaled!.minX),
                       Int(selected_image!.size.width - image_draw_rect_scaled!.maxX),
                       Int(image_draw_rect_scaled!.minY),
                       Int(selected_image!.size.height - image_draw_rect_scaled!.maxY)]
        Templates.edit_template(originalName: originalName,
                                name: templateName,
                                image: selected_image!,
                                margins: margins,
                                font_size: Int(font_size))
    }
}

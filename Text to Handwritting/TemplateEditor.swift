//
//  TemplateEditor.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct TemplateEditor: View {
    @Binding var document: TemplateDocument
    @State var showingImagePicker = false
    
    var body: some View {
        ZStack {
            ImageRectSelector(document: $document)
            VStack(alignment: .center, spacing: UIScreen.main.bounds.height-200) {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                }
                NumberSelector(value: $document.template.font_size, minValue: 5, maxValue: 200, label: "Font size")
                    .frame(width: 300)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                document.template.background = image.pngData()!
                showingImagePicker = false
            }
        }
    }
}

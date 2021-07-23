////
////  TemplateCreator.swift
////  Text to Handwritting
////
////  Created by Daniel Long on 7/14/21.
////
//
//import Foundation
//import SwiftUI
//
//struct TemplateCreator: View {
//    @State var selected_image: UIImage?
//    @State var image_draw_rect = CGRect(x: 0, y: 0, width: 100, height: 100)
//    @State var image_draw_rect_scaled: CGRect? = nil
//    @State var showingImagePicker = false
//    @State var font_size: Float = 20
//    @State var showingSaveDialog = false
//    @State var templateName = ""
//    @Binding var shown: templateViews?
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 10) {
//            Text("Create New Template")
//            TextField("Template Name", text: $templateName)
//                .frame(width: 200)
//                .multilineTextAlignment(.center)
//                .autocapitalization(.none)
//            Button("Select Image") {
//                showingImagePicker = true
//            }
//            if selected_image != nil {
//                ImageOptionsDisplay(image: $selected_image, rect: $image_draw_rect, real_rect: $image_draw_rect_scaled, font_size: $font_size)
//            }
//            NumberSelector(value: $font_size, minValue: 5, maxValue: 200, label: "Font size")
//                .frame(width: 300)
//            Button("Save Template") {
//                showingSaveDialog = true
//            }
//            .foregroundColor(.green)
//            Button("Cancel") {
//                shown = nil
//            }
//            .foregroundColor(.red)
//        }
//        .sheet(isPresented: $showingImagePicker) {
//            ImagePicker(sourceType: .photoLibrary) { image in
//                self.selected_image = image
//                showingImagePicker = false
//            }
//        }
//        .alert(isPresented: $showingSaveDialog) {
//            if selected_image == nil {
//                return Alert(title: Text("Save"), message: Text("Cannot save, select an image first"), dismissButton: .cancel())
//            }
//            else if templateName == "" {
//                return Alert(title: Text("Save"), message: Text("Cannot save, name the template first"), dismissButton: .cancel())
//            }
//            else {
//                return Alert(title: Text("Save"),
//                      message: Text("Are you sure you want to save this template as " + templateName + "?"),
//                      primaryButton: .default(Text("Save")) {
//                        self.save_template()
//                        shown = nil
//                      },
//                      secondaryButton: .cancel()
//                )
//            }
//        }
//    }
//
//    func save_template() {
//        let margins = [Int(image_draw_rect_scaled!.minX),
//                       Int(selected_image!.size.width - image_draw_rect_scaled!.maxX),
//                       Int(image_draw_rect_scaled!.minY),
//                       Int(selected_image!.size.height - image_draw_rect_scaled!.maxY)]
//        Templates.createTemplate(name: templateName,
//                                  image: selected_image!,
//                                  margins: margins,
//                                  fontSize: Int(font_size))
//    }
//}

//
//  TemplateEditor.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI
import Photos

struct TemplateEditor: View {
    @Binding var document: TemplateDocument
    @State var showingImagePicker = false
    @State var showingNoPermissionAlert = false
    @State var realTextColor: Color = Color(white: 1.0)
    
    var body: some View {
        VStack {
            Button(action: {
                if PHPhotoLibrary.checkPhotoSavePermission() {
                    showingImagePicker = true
                } else {
                    showingNoPermissionAlert = true
                }
            }) {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            GeometryReader { geometry in
                let displayScale = Double(min(
                    geometry.size.width/document.object.getBackground().size.width,
                    geometry.size.height/document.object.getBackground().size.height
                ))
                ImageRectSelector(document: $document, scale: displayScale)
                    .scaleEffect(CGFloat(displayScale))
                    .offset(CGSize(width: -document.object.getBackground().size.width/2 + geometry.size.width/2,
                                   height: -document.object.getBackground().size.height/2 + geometry.size.height/2))
            }.padding()
            NumberSelector(value: $document.object.fontSize, minValue: 5, maxValue: 200, label: "Font size")
                .frame(width: 300)
            ColorPicker("Font color", selection: $realTextColor)
                .onChange(of: realTextColor) { value in
                    document.object.textColor = realTextColor.cgColor!.components!.map { Float($0) }
                }
                .frame(width: 300)
            Picker("Font style", selection: $document.object.writingStyle) {
                Text("Pen").tag("Pen")
                    .font(.body)
                Text("Pencil").tag("Pencil")
                    .font(.body)
                Text("Marker").tag("Marker")
                    .font(.body)
            }
            .frame(width: 300, height: 150)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                document.object.background = image.pngData()!
                showingImagePicker = false
            }
        }
        .alert(isPresented: $showingNoPermissionAlert) {
            Alert(title: Text("Cannot open photos"), message: Text("Text to Handwritting does not have permission to acess your photo library"), dismissButton: .default(Text("Ok")))
        }
        .onAppear() {
            realTextColor = Color(.sRGB, red: Double(document.object.textColor[0]), green: Double(document.object.textColor[1]), blue: Double(document.object.textColor[2]), opacity: Double(document.object.textColor[3]))
        }
    }
}

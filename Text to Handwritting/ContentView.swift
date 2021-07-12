//
//  ContentView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @State private var showingGenerationOptions = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center, spacing: 10) {
                Button("generate image") {
                    showingGenerationOptions.toggle()
                }
            }
            TextEditor(text: $document.text)
        }
        
        .sheet(isPresented: $showingGenerationOptions) {
            OptionsView(document: $document, shown: $showingGenerationOptions)
        }
    }
}

struct OptionsView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @Binding var shown: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 200) {
            VStack(alignment: .center, spacing: 20) {
                Text("Font")
                FontSelector()
            }
            VStack(alignment: .center, spacing: 20) {
                Text("Paper")
                TemplateSelector()
            }
            HStack(alignment: .center, spacing: 50) {
                Button("generate") {
                    document.createImage()
                }
                Button("cancel") {
                    shown = false
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct TemplateSelector: View {
    @State private var selectedBackground = Templates.primary_template
    @State var showingTemplateCreation = false
    @State var showingTemplateDeletionConfirmation = false
    @State var showingTemplateEditing = false
    private var item_width = CGFloat(180)
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 50) {
                Button("Add template") {
                    showingTemplateCreation = true
                }
                Button("Edit slected template") {
                    showingTemplateEditing = true
                }
                Button("Delete selected template") {
                    showingTemplateDeletionConfirmation = true
                }
                .foregroundColor(.red)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(Array(Templates.templates.keys), id: \.self) { option in
                        VStack(alignment: .center, spacing: 5) {
                            Text(option)
                            Image(uiImage: Templates.templates[option]!.get_bg())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black)
                                .frame(width: item_width)
                                .tag(option)
                        }
                        .foregroundColor(selectedBackground == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ Templates.primary_template = option; selectedBackground = option}))
                    }
                }
            }.frame(width: min(CGFloat(Templates.templates.count) * (item_width), CGFloat((item_width) * 3)), alignment: .center)
        }
        .sheet(isPresented: $showingTemplateCreation) {
            TemplateCreator(shown: $showingTemplateCreation)
        }
        .alert(isPresented: $showingTemplateDeletionConfirmation) {
            Alert(title: Text("Delete Template"),
                  message: Text("Are you sure you want to delete template \"" + Templates.get_template().name + "\"?"),
                  primaryButton: .destructive(Text("Yes")) {
                    Templates.delete_template(name: Templates.get_template().name)
                  },
                  secondaryButton: .cancel())
        }
    }
}

struct FontSelector: View {
    @State private var selectedFont = CharSets.primary_set
    private var item_width = CGFloat(150)
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(CharSets.sets.keys), id: \.self) { option in
                    Text(option)
                        .foregroundColor(selectedFont == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ CharSets.primary_set = option; selectedFont = option}))
                        .frame(width: item_width, height: 50)
                        .border(Color.black, width: 2)
                }
            }
        }.frame(width: min(CGFloat(CharSets.sets.count) * item_width, CGFloat(item_width * 4)), alignment: .center)
    }
}

struct TemplateCreator: View {
    @State var selected_image: UIImage?
    @State var image_draw_rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    @State var showingImagePicker = false
    @State var font_size: Float = 20
    @State var showingSaveDialog = false
    @State var templateName = ""
    @Binding var shown: Bool
    
    var imageScale = 0.5
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Create New Template")
            TextField("Template Name", text: $templateName)
                .frame(width: 200)
                .multilineTextAlignment(.center)
            Button("Select Image") {
                showingImagePicker = true
            }
            if selected_image != nil {
                ImageOptionsDisplay(image: $selected_image, rect: $image_draw_rect, font_size: $font_size)
            }
            NumberSelector(value: $font_size, minValue: 5, maxValue: 200, label: "Font size")
                .frame(width: 300)
            Button("Save Template") {
                showingSaveDialog = true
            }
            .foregroundColor(.green)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                self.selected_image = image
                showingImagePicker = false
            }
        }
        .alert(isPresented: $showingSaveDialog) {
            if selected_image == nil {
                return Alert(title: Text("Save"), message: Text("Cannot save, select an image first"), dismissButton: .cancel())
            }
            else if templateName == "" {
                return Alert(title: Text("Save"), message: Text("Cannot save, name the template first"), dismissButton: .cancel())
            }
            else {
                return Alert(title: Text("Save"),
                      message: Text("Are you sure you want to save this template as " + templateName + "?"),
                      primaryButton: .default(Text("Save")) {
                        self.save_template()
                        shown = false
                      },
                      secondaryButton: .cancel()
                )
            }
        }
    }
    
    func save_template() {
        let margins = [Int(image_draw_rect.minX/CGFloat(imageScale)),
                       Int((image_draw_rect.width - image_draw_rect.maxX)/CGFloat(imageScale)),
                       Int(image_draw_rect.minY/CGFloat(imageScale)),
                       Int((image_draw_rect.height - image_draw_rect.maxY)/CGFloat(imageScale))]
        Templates.create_template(name: templateName,
                                  image: self.selected_image!,
                                  margins: margins,
                                  font_size: Int(self.font_size))
    }
}

struct NumberSelector: View {
    @Binding var value: Float
    @State var minValue: Float
    @State var maxValue: Float
    @State var label: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(label)
            Slider(value: $value,
                   in: minValue...maxValue,
                   step: 1.0,
                   onEditingChanged: {_ in },
                   minimumValueLabel: Text(String(Int(minValue))),
                   maximumValueLabel: Text(String(Int(maxValue))),
                   label: {})
            Text(String(value))
        }
    }
}

struct ImageOptionsDisplay: View {
    @Binding var image: UIImage?
    
    @State var selectedCorner: Corners?
    enum Corners: Identifiable {
        case topLeft, topRight, bottomLeft, bottomRight, fullRect
        var id: Int {
            hashValue
        }
    }
    
    @Binding var rect: CGRect
    @Binding var font_size: Float
    @State var initial_rel_dist: CGPoint?
    
    var body: some View {
        let display_scale = 500/Double(image!.size.width)
        let width = Double(image!.size.width) * display_scale
        let height = Double(image!.size.height) * display_scale
        return Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 500)
            .border(Color.black, width: 2)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { pos in
                        if selectedCorner == nil {
                            let toTopLeft = sqrt(pow(pos.location.x - rect.minX,2) + pow(pos.location.y - rect.minY,2))
                            let toTopRight = sqrt(pow(pos.location.x - rect.maxX,2) + pow(pos.location.y - rect.minY,2))
                            let toBottomLeft = sqrt(pow(pos.location.x - rect.minX,2) + pow(pos.location.y - rect.maxY,2))
                            let toBottomRight = sqrt(pow(pos.location.x - rect.maxX,2) + pow(pos.location.y - rect.maxY,2))
                            let closest = min(toTopLeft, min(toTopRight, min(toBottomLeft, toBottomRight)))
                            if closest > 25 {
                                selectedCorner = .fullRect
                            }
                            else if closest == toTopLeft {
                                selectedCorner = .topLeft
                            }
                            else if closest == toTopRight {
                                selectedCorner = .topRight
                            }
                            else if closest == toBottomLeft {
                                selectedCorner = .bottomLeft
                            }
                            else if closest == toBottomRight {
                                selectedCorner = .bottomRight
                            }
                            initial_rel_dist = CGPoint(x: rect.origin.x - pos.location.x, y: rect.origin.y - pos.location.y)
                        }
                        var rect2: CGRect?
                        switch selectedCorner {
                        case .topLeft:
                            rect2 = CGRect(x: pos.location.x, y: pos.location.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: rect.size.height + (rect.origin.y - pos.location.y))
                        case .topRight:
                            rect2 = CGRect(x: rect.origin.x, y: pos.location.y, width: pos.location.x - rect.origin.x, height: rect.size.height + (rect.origin.y - pos.location.y))
                        case .bottomLeft:
                            rect2 = CGRect(x: pos.location.x, y: rect.origin.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: pos.location.y - rect.origin.y)
                        case.bottomRight:
                            rect2 = CGRect(x: rect.origin.x, y: rect.origin.y, width: pos.location.x - rect.origin.x, height: pos.location.y - rect.origin.y)
                        case .fullRect:
                            rect2 = CGRect(x: pos.location.x + initial_rel_dist!.x, y: pos.location.y + initial_rel_dist!.y, width: rect.width, height: rect.height)
                        case .none:
                            print("This should never happen. The selected corner is somehow null, despite having been just set.")
                        }
                        rect = closest_valid_rect(oldRect: rect, newRect: rect2!, boundingRect: CGRect(x: 0, y: 0, width: width, height: height), minSize: CGSize(width: 50, height: 50))
                    }
                    .onEnded {_ in
                        selectedCorner = nil
                    }
            )
            .overlay(
                Rectangle()
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .overlay(
                        VStack(alignment: .center, spacing: CGFloat(Double(font_size)*display_scale)) {
                            ForEach(1..<max(1,Int(rect.height/(CGFloat(Double(font_size)*display_scale)))), id: \.self) {i in
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 1)
                                    .frame(width: rect.width, height: 1)
                            }
                        }
                        .frame(width: rect.width, height: rect.height)
                        .clipped()
                        .offset(x: CGFloat(-width*0.5) + rect.width/2 + rect.origin.x,
                                y: CGFloat(-height*0.5) + rect.height/2 + rect.origin.y)
                    )
            )
    }
    
    func closest_valid_rect(oldRect: CGRect, newRect: CGRect, boundingRect: CGRect, minSize: CGSize) -> CGRect{
        //logic that deals with constraining the CGRect to a real rectangle with positive area. Could be condensed, but this is by far the clearest way to write it.
        var resultRect = newRect
        if resultRect.minX < boundingRect.minX {
            resultRect.origin.x = 0
            resultRect.size.width = oldRect.width
        }
        if resultRect.minY < boundingRect.minY {
            resultRect.origin.y = 0
            resultRect.size.height = oldRect.height
        }
        if resultRect.maxX > boundingRect.maxX {
            resultRect.origin.x = boundingRect.maxX - oldRect.width
            resultRect.size.width = oldRect.width
        }
        if newRect.maxY > boundingRect.maxY {
            resultRect.origin.y = boundingRect.maxY - oldRect.height
            resultRect.size.height = oldRect.height
        }
        if resultRect.size.width < minSize.width {
            resultRect.origin.x = oldRect.origin.x
            resultRect.size.width = minSize.width
        }
        if resultRect.size.height < minSize.height {
            resultRect.origin.y = oldRect.origin.y
            resultRect.size.height = minSize.height
        }
        return resultRect
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Text_to_HandwrittingDocument()))
        TemplateSelector()
    }
}

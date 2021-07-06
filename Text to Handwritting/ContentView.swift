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
    private var item_width = CGFloat(180)
    var body: some View {
        VStack {
            Button("Add template") {
                showingTemplateCreation = true
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
                                .frame(width: item_width, height: 220)
                                .tag(option)
                        }
                        .foregroundColor(selectedBackground == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ Templates.primary_template = option; selectedBackground = option}))
                    }
                }
            }.frame(width: min(CGFloat(Templates.templates.count) * (item_width), CGFloat((item_width) * 3)), alignment: .center)
        }
        .sheet(isPresented: $showingTemplateCreation) {
            TemplateCreator()
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

enum ActiveTemplateCreatorWindow: Identifiable {
    case imageSelector, rectSelector
    var id: Int {
        hashValue
    }
}

struct TemplateCreator: View {
    @State var selected_image: UIImage?
    @State var image_draw_rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    @State var currentView: ActiveTemplateCreatorWindow?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Create New Template")
            Button("Select Image") {
                currentView = .imageSelector
            }
            if selected_image != nil {
                Image(uiImage: selected_image!)
                    .resizable()
                    .frame(width: 170, height: 220)
            }
        }
        .sheet(item: $currentView) { item in
            switch item {
            case .imageSelector:
                ImagePicker(sourceType: .photoLibrary) { image in
                    self.selected_image = image
                    currentView = .rectSelector
                }
            case .rectSelector:
                ImageRectSelector(image: selected_image!, shown: $currentView, rect: $image_draw_rect)
            }
        }
    }
}

struct ImageRectSelector: View {
    @State var image: UIImage
    @Binding var shown: ActiveTemplateCreatorWindow?
    
    @State var selectedCorner: Corners?
    enum Corners: Identifiable {
        case topLeft, topRight, bottomLeft, bottomRight, fullRect
        var id: Int {
            hashValue
        }
    }
    
    @Binding var rect: CGRect
    @State var initial_rel_dist: CGPoint?
    
    var body: some View {
        VStack {
            Text("Select the writing area of the image")
            Image(uiImage: image)
                .resizable()
                .frame(width: 340, height: 440)
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
                            switch selectedCorner {
                            case .topLeft:
                                rect = CGRect(x: pos.location.x, y: pos.location.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: rect.size.height + (rect.origin.y - pos.location.y))
                            case .topRight:
                                rect = CGRect(x: rect.origin.x, y: pos.location.y, width: pos.location.x - rect.origin.x, height: rect.size.height + (rect.origin.y - pos.location.y))
                            case .bottomLeft:
                                rect = CGRect(x: pos.location.x, y: rect.origin.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: pos.location.y - rect.origin.y)
                            case.bottomRight:
                                rect = CGRect(x: rect.origin.x, y: rect.origin.y, width: pos.location.x - rect.origin.x, height: pos.location.y - rect.origin.y)
                            case .fullRect:
                                rect.origin.x = pos.location.x + initial_rel_dist!.x
                                rect.origin.y = pos.location.y + initial_rel_dist!.y
                            case .none:
                                print("This should never happen. The selected corner is somehow null, despite having been just set.")
                            }
                        }
                        .onEnded {_ in
                            selectedCorner = nil
                        }
                )
                .overlay(
                    Rectangle()
                        .stroke(Color.red, lineWidth: 5)
                        .frame(width: rect.size.width, height: rect.size.height)
                        .position(x: rect.midX, y: rect.midY)
                )
            Button("Done") {
                shown = nil
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Text_to_HandwrittingDocument()))
        TemplateSelector()
        TemplateCreator()
    }
}

//
//  WritingView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/15/21.
//

import Foundation
import SwiftUI
import PencilKit

struct WritingView: View {
    @Binding var document: CharSetDocument
    @State var chars: String
    @State var selection: String
    @State var canvas = PKCanvasView()
    @State var canvasScale: Double = 1.0
    @State var previousScale: Double = 1.0
    @State var toolWidth: Double = 20.0
    @ScaledMetric var imageSize: CGFloat = 50
    @ScaledMetric(relativeTo: .largeTitle) var canvasButtonsSize: CGFloat = 50
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Write " + selection)
                .font(.title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 25) {
                    ForEach(0..<document.object.getImages(char: selection).count, id: \.self) { i in
                        ZStack {
                            let image = document.object.getImages(char: selection)[i]
                            Image(uiImage: image.image(from: CGRect(x: 0, y: 0, width: 256, height: 256), scale: 1.0))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black, width: 2)
                            Button(action: {
                                self.deleteImage(imageIndex: i)
                            }) {
                                Image(systemName: "xmark.circle")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
                                    )
                            }
                            .frame(width: imageSize, height: imageSize, alignment: .topTrailing)
                            .offset(x: -2, y: 2)
                        }
                    }.frame(width: imageSize, height: imageSize)
                }
                .padding()
                .frame(height: imageSize)
            }
            .frame(height: imageSize)
            .padding(.horizontal)
            GeometryReader { geometry in
                VStack { // workaround - geometry reader does not center children; add VStack set to geometry size to fix.
                    VStack {
                        HStack(alignment: .center, spacing: 10) {
                            Button(action: {
                                if canvas.drawing.strokes.count != 0 {
                                    self.saveImage(image: canvas.drawing.transformed(using: CGAffineTransform(scaleX: 256.0/canvas.bounds.width, y: 256.0/canvas.bounds.height)))
                                }
                                canvas.drawing = PKDrawing()
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                            Button(action: {
                                if canvas.drawing.strokes.count != 0 {
                                    self.saveImage(image: canvas.drawing.transformed(using: CGAffineTransform(scaleX: 256.0/canvas.bounds.width, y: 256.0/canvas.bounds.height)))
                                }
                                canvas.drawing = PKDrawing()
                                let index = chars.firstIndex(of: Character(selection))!
                                if String(chars.first!) != selection {
                                    selection = String(chars[chars.index(before: index)])
                                } else {
                                    selection = String(chars.last!)
                                }
                            }) {
                                Image(systemName: "backward")
                            }
                            Button(action: {
                                if canvas.drawing.strokes.count != 0 {
                                    self.saveImage(image: canvas.drawing.transformed(using: CGAffineTransform(scaleX: 256.0/canvas.bounds.width, y: 256.0/canvas.bounds.height)))
                                }
                                canvas.drawing = PKDrawing()
                                let index = chars.firstIndex(of: Character(selection))!
                                if String(chars.last!) != selection {
                                    selection = String(chars[chars.index(after: index)])
                                } else {
                                    selection = String(chars.first!)
                                }
                            }) {
                                Image(systemName: "forward")
                            }
                            Button(action: {
                                canvas.drawing = PKDrawing()
                            }) {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.red)
                        }
                        .font(.largeTitle)
                        Canvas(canvasView: $canvas)
                            .background(
                                Image("writingbackground")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            )
                            .aspectRatio(CGFloat(1.0), contentMode: .fit)
                            .border(Color.black, width: 2)
                    }.frame(width: max(50 + canvasButtonsSize, (50 + canvasButtonsSize) * CGFloat(1.0 - canvasScale) + geometry.size.width * CGFloat(canvasScale)), height: max(50 + canvasButtonsSize, (50 + canvasButtonsSize) * CGFloat(1.0 - canvasScale) + geometry.size.height * CGFloat(canvasScale)))
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
            VStack {
                Slider(value: $canvasScale, in: 0.0...1, step: 0.01, onEditingChanged: { _ in }, label: {})
                    .padding(.horizontal, 50)
                .onChange(of: canvasScale) { _ in
                    UserDefaults.standard.setValue(canvasScale, forKey: "writingViewCanvasScale")
                    let percentChange = canvasScale/previousScale
                    canvas.drawing.transform(using: CGAffineTransform(scaleX: CGFloat(percentChange), y: CGFloat(percentChange)))
                    previousScale = canvasScale
                }
                Text("Writing Canvas Scale")
            }
            VStack {
                Slider(value: $toolWidth, in: 5.0...50.0, step: 0.1, onEditingChanged: { _ in }, label: {})
                    .padding(.horizontal, 50)
                .onChange(of: toolWidth) { _ in
                    canvas.tool = PKInkingTool(.pen, color: .black, width: CGFloat(toolWidth))
                    UserDefaults.standard.setValue(toolWidth, forKey: "writingViewToolWidth")
                }
                Text("Pen width")
            }
        }
        .padding(25)
        .onDisappear() {
            if canvas.drawing.strokes.count != 0 {
                self.saveImage(image: canvas.drawing.transformed(using: CGAffineTransform(scaleX: 256.0/canvas.bounds.width, y: 256.0/canvas.bounds.height)))
                canvas.drawing = PKDrawing()
            }
        }
        .onAppear() {
            if UserDefaults.standard.double(forKey: "writingViewCanvasScale") != 0.0 {
                canvasScale = UserDefaults.standard.double(forKey: "writingViewCanvasScale")
            } else {
                UserDefaults.standard.setValue(1.0, forKey: "writingViewCanvasScale")
            }
            
            if UserDefaults.standard.double(forKey: "writingViewToolWidth") != 0.0 {
                toolWidth = UserDefaults.standard.double(forKey: "writingViewToolWidth")
            } else {
                UserDefaults.standard.setValue(20.0, forKey: "writingViewToolWidth")
            }
        }
    }
    
    func saveImage(image: PKDrawing) {
        if document.object.available_chars.firstIndex(of: Character(selection)) == nil {
            document.object.available_chars += selection
        }
        
        let s = document.object.characters[selection] ?? []
        document.object.characters[selection] = s + [image]
    }
    
    func deleteImage(imageIndex: Int) {
        if document.object.characters[selection]!.count <= 1 {
            document.object.available_chars.remove(at: document.object.available_chars.firstIndex(of: Character(selection))!)
            document.object.characters.removeValue(forKey: selection)
            return
        }
    }
}

//canvas class modified from https://www.hackingwithswift.com/forums/swiftui/pencilkit-with-swiftui/59
struct Canvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 20)
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
}

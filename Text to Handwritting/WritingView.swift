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
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Write " + selection)
                .font(.title)
            let scrollWidth = max(min(67 * document.object.getImages(char: selection).count + 25 * (document.object.getImages(char: selection).count - 1), 370), 0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 25) {
                    ForEach(0..<document.object.getImages(char: selection).count, id: \.self) { i in
                        let image = document.object.getImages(char: selection)[i]
                        Image(uiImage: image.image(from: CGRect(x: 0, y: 0, width: 256, height: 256), scale: 1.0))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .border(Color.black, width: 2)
                            .overlay(
                                Button(action: {
                                    self.deleteImage(imageIndex: i)
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                }
                                .offset(x: 25, y: -25)
                            )
                    }
                }
                .frame(width: CGFloat(scrollWidth), height: 70)
            }
            .frame(width: CGFloat(scrollWidth), height: 70)
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
                .frame(maxWidth: 500 * CGFloat(canvasScale), maxHeight: 500 * CGFloat(canvasScale))
            VStack {
                Slider(value: $canvasScale, in: 0.2...1, step: 0.01, onEditingChanged: {_ in
                    UserDefaults.standard.setValue(canvasScale, forKey: "writingViewCanvasScale")
                }, label: {})
                    .padding(.horizontal, 50)
                .onChange(of: canvasScale) { _ in
                    let percentChange = canvasScale/previousScale
                    canvas.drawing.transform(using: CGAffineTransform(scaleX: CGFloat(percentChange), y: CGFloat(percentChange)))
                    previousScale = canvasScale
                }
                Text("Writing Canvas Scale")
            }
            VStack {
                Slider(value: $toolWidth, in: 5.0...50.0, step: 0.1, onEditingChanged: {_ in
                    UserDefaults.standard.setValue(toolWidth, forKey: "writingViewToolWidth")
                }, label: {})
                    .padding(.horizontal, 50)
                .onChange(of: toolWidth) { _ in
                    canvas.tool = PKInkingTool(.pen, color: .black, width: CGFloat(toolWidth))
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
                canvasScale = UserDefaults.standard.double(forKey: "writingViewToolWidth")
            } else {
                UserDefaults.standard.setValue(20.0, forKey: "writingViewToolWidth")
            }
        }
    }
    
    func saveImage(image: PKDrawing) {
        if document.object.availiable_chars.firstIndex(of: Character(selection)) == nil {
            document.object.availiable_chars += selection
        }
        
        if document.object.characters.keys.firstIndex(of: selection) != nil {
            document.object.characters[selection]!.append(image)
        } else {
            document.object.characters[selection] = [image]
        }
        
        if document.object.charlens.keys.firstIndex(of: selection) != nil {
            var sum = document.object.charlens[selection]! * Float(document.object.characters[selection]!.count - 1)
            sum += Float(image.bounds.width)
            document.object.charlens[selection]! = sum / Float(document.object.characters[selection]!.count)
        } else {
            document.object.charlens[selection] = Float(image.bounds.width)
        }
    }
    
    func deleteImage(imageIndex: Int) {
        if document.object.characters[selection]!.count <= 1 {
            document.object.availiable_chars.remove(at: document.object.availiable_chars.firstIndex(of: Character(selection))!)
            document.object.characters.removeValue(forKey: selection)
            document.object.charlens.removeValue(forKey: selection)
            return
        }
        
        var sum = document.object.charlens[selection]! * Float(document.object.characters[selection]!.count)
        let image = document.object.characters[selection]![imageIndex]
        sum -= Float(image.bounds.width)
        
        document.object.characters[selection]!.remove(at: imageIndex)
        document.object.charlens[selection]! = sum / Float(document.object.characters[selection]!.count)
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

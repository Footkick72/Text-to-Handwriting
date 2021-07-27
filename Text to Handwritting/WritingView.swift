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
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Write " + selection)
                .font(.title)
            let scrollWidth = max(min(67 * document.object.getImages(char: selection).count + 25 * (document.object.getImages(char: selection).count - 1), 370), 0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 25) {
                    ForEach(0..<document.object.getImages(char: selection).count, id: \.self) { i in
                        Image(uiImage: document.object.getImages(char: selection)[i])
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
                    let drawing = canvas.drawing
                    if drawing.strokes.count != 0 {
                        let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                        let scaler = canvas.bounds.width / 256.0
                        let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                        canvas.drawing = PKDrawing()
                        self.saveImage(image: scaled)
                    }
                }) {
                    Image(systemName: "checkmark.circle")
                }
                Button(action: {
                    let drawing = canvas.drawing
                    if drawing.strokes.count != 0 {
                        let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                        let scaler = canvas.bounds.width / 256.0
                        let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                        self.saveImage(image: scaled)
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
                    let drawing = canvas.drawing
                    if drawing.strokes.count != 0 {
                        let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                        let scaler = canvas.bounds.width / 256.0
                        let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                        self.saveImage(image: scaled)
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
            .font(.title)
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
                Text("Writing Canvas Scale")
            }
        }
        .padding(25)
        .onDisappear() {
            let drawing = canvas.drawing
            if drawing.strokes.count != 0 {
                let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                let scaler = canvas.bounds.width / 256.0
                let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                canvas.drawing = PKDrawing()
                self.saveImage(image: scaled)
            }
        }
        .onAppear() {
            canvasScale = UserDefaults.standard.double(forKey: "writingViewCanvasScale")
        }
    }
    
    func saveImage(image: UIImage) {
        if document.object.availiable_chars.firstIndex(of: Character(selection)) == nil {
            document.object.availiable_chars += selection
        }
        
        if document.object.characters.keys.firstIndex(of: selection) != nil {
            document.object.characters[selection]!.append(image.pngData()!)
        } else {
            document.object.characters[selection] = [image.pngData()!]
        }
        
        if document.object.charlens.keys.firstIndex(of: selection) != nil {
            var sum = document.object.charlens[selection]! * Float(document.object.characters[selection]!.count - 1)
            let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
            let scaler = 1.0 / Float(image.size.width)
            sum += Float(box.width) * scaler
            document.object.charlens[selection]! = sum / Float(document.object.characters[selection]!.count)
        } else {
            let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
            let scaler = 1.0 / Float(image.size.width)
            document.object.charlens[selection] = Float(box.width) * scaler
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
        let image = UIImage(data: document.object.characters[selection]![imageIndex])!
        let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
        let scaler = 1.0 / Float(image.size.width)
        sum -= Float(box.width) * scaler
        
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

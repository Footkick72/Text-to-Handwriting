//
//  WritingView.swift
//  Text to Handwritting
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
    @Binding var shown: Bool
    @State var images: Array<UIImage>
    
    @State var canvas = PKCanvasView()
    
    var body: some View {
        VStack {
            Text("Write a " + selection)
                .font(.title)
            let scrollWidth = max(min(50 * images.count + 10 * (images.count - 1), 350), 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    ForEach(0..<images.count, id: \.self) { i in
                        Image(uiImage: images[i])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .border(Color.black, width: 2)
                            .onTapGesture {
                                self.deleteImage(image: images[i])
                                images.remove(at: i)
                            }
                    }
                }
            }
            .frame(width: CGFloat(scrollWidth), height: 50)
            Canvas(canvasView: $canvas)
                .background(
                    Image("writingbackground")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .aspectRatio(CGFloat(1.0), contentMode: .fit)
                .border(Color.black, width: 2)
                .scaleEffect(0.8)
            HStack(alignment: .center, spacing: 10) {
                Button(action: {
                    let drawing = canvas.drawing
                    let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                    let scaler = canvas.bounds.width / 256.0
                    let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                    images.append(scaled)
                    canvas.drawing = PKDrawing()
                    self.saveImage(image: scaled)
                }) {
                    Image(systemName: "checkmark.circle")
                }
                Button(action: {
                    canvas.drawing = PKDrawing()
                    let index = chars.firstIndex(of: Character(selection))!
                    if String(chars.first!) != selection {
                        selection = String(chars[chars.index(before: index)])
                    } else {
                        selection = String(chars.last!)
                    }
                    images = document.charset.getImages(char: selection)
                }) {
                    Image(systemName: "backward")
                }
                Button(action: {
                    canvas.drawing = PKDrawing()
                    let index = chars.firstIndex(of: Character(selection))!
                    if String(chars.last!) != selection {
                        selection = String(chars[chars.index(after: index)])
                    } else {
                        selection = String(chars.first!)
                    }
                    images = document.charset.getImages(char: selection)
                }) {
                    Image(systemName: "forward")
                }
                Button(action: {
                    canvas.drawing = PKDrawing()
                }) {
                    Image(systemName: "trash")
                }
                .foregroundColor(.red)
                Button(action: {
                    shown = false
                }) {
                    Image(systemName: "xmark.circle")
                }
                .foregroundColor(.red)
            }
            .font(.title)
        }
    }
    
    func saveImage(image: UIImage) {
        if document.charset.availiable_chars.firstIndex(of: Character(selection)) == nil {
            document.charset.availiable_chars += selection
        }
        
        if document.charset.characters.keys.firstIndex(of: selection) != nil {
            document.charset.characters[selection]!.append(image.pngData()!)
        } else {
            document.charset.characters[selection] = [image.pngData()!]
        }
        
        if document.charset.charlens.keys.firstIndex(of: selection) != nil {
            var sum = document.charset.charlens[selection]! * Float(document.charset.characters[selection]!.count - 1)
            let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
            let scaler = 1.0 / Float(image.size.width)
            sum += Float(box.width) * scaler
            document.charset.charlens[selection]! = sum / Float(document.charset.characters[selection]!.count)
        } else {
            let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
            let scaler = 1.0 / Float(image.size.width)
            document.charset.charlens[selection] = Float(box.width) * scaler
        }
    }
    
    func deleteImage(image: UIImage) {
        if document.charset.characters[selection]!.count <= 1 {
            document.charset.availiable_chars.remove(at: document.charset.availiable_chars.firstIndex(of: Character(selection))!)
            document.charset.characters.removeValue(forKey: selection)
            document.charset.charlens.removeValue(forKey: selection)
            return
        }
        
        var sum = document.charset.charlens[selection]! * Float(document.charset.characters[selection]!.count)
        let box = image.cropAlpha(cropVertical: true, cropHorizontal: true).size
        let scaler = 1.0 / Float(image.size.width)
        sum -= Float(box.width) * scaler
        
        document.charset.characters[selection]!.remove(at: document.charset.characters[selection]!.firstIndex(of: image.pngData()!)!)
        document.charset.charlens[selection]! = sum / Float(document.charset.characters[selection]!.count)
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

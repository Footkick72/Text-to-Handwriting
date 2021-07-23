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
                                images.remove(at: i)
                            }
                    }
                }
            }
            .frame(width: CGFloat(scrollWidth), height: 50)
            Canvas(canvasView: $canvas)
                .opacity(0.5)
                .background(
                    Image(uiImage: UIImage(imageLiteralResourceName: "writingbackground.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .aspectRatio(CGFloat(1.0), contentMode: .fit)
                .border(Color.black, width: 2)
                .scaleEffect(0.8)
            HStack(alignment: .center, spacing: 50) {
                Button("Save") {
                    let drawing = canvas.drawing
                    let drawn_area = drawing.image(from: canvas.bounds, scale: 1.0)
                    let scaler = canvas.bounds.width / 256.0
                    let scaled = UIImage(cgImage: drawn_area.cgImage!, scale: CGFloat(scaler), orientation: drawn_area.imageOrientation)
                    images.append(scaled)
                    canvas.drawing = PKDrawing()
                }
                Button("Previous") {
                    canvas.drawing = PKDrawing()
                    document.charset.setCharacters(char: selection, images: images)
                    let index = chars.firstIndex(of: Character(selection))!
                    if String(chars.first!) != selection {
                        selection = String(chars[chars.index(before: index)])
                    } else {
                        selection = String(chars.last!)
                    }
                    images = document.charset.getImages(char: selection)
                }
                Button("Next") {
                    canvas.drawing = PKDrawing()
                    document.charset.setCharacters(char: selection, images: images)
                    let index = chars.firstIndex(of: Character(selection))!
                    if String(chars.last!) != selection {
                        selection = String(chars[chars.index(after: index)])
                    } else {
                        selection = String(chars.first!)
                    }
                    images = document.charset.getImages(char: selection)
                }
                Button("Clear") {
                    canvas.drawing = PKDrawing()
                }
                .foregroundColor(.red)
                Button("Exit") {
                    shown = false
                    document.charset.setCharacters(char: selection, images: images)
                }
                .foregroundColor(.red)
            }
            .font(.title)
        }
    }
}

//canvas class modified from https://www.hackingwithswift.com/forums/swiftui/pencilkit-with-swiftui/59
struct Canvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) { }
}

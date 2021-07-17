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
    
    @State var chars: String
    @State var selection: String
    @Binding var shown: Bool
    @State var images: Array<UIImage> = []
    
    @State var canvas = PKCanvasView()
    
    var body: some View {
        VStack {
            Text("Write a " + selection)
                .font(.title)
            HStack(alignment: .center, spacing: 10) {
                ForEach(0...4, id: \.self) { i in
                    Rectangle()
                        .foregroundColor(images.count <= i ? .red : .green)
                        .opacity(0.8)
                        .frame(width: 50, height: 50)
                }
            }
            .frame(height: 50)
            Canvas(canvasView: $canvas)
                .opacity(0.5)
                .background(
                    Image(uiImage: UIImage(imageLiteralResourceName: "writingbackground.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                )
                .aspectRatio(CGFloat(1.0), contentMode: .fit)
                .border(Color.black, width: CGFloat(2))
                .scaleEffect(0.8)
            HStack(alignment: .center, spacing: 50) {
                Button("Save character") {
                    let drawing = canvas.drawing
                    images.append(drawing.image(from: drawing.bounds, scale: 1.0))
                    canvas.drawing = PKDrawing()
                }
                Button("Next character") {
                    CharSets.add_characters_to_set(char: selection, images: images)
                    let index = chars.firstIndex(of: Character(selection))!
                    selection = String(chars[chars.index(after: index)])
                    images = []
                }
                .disabled(images.count < 5 ? true : false)
                Button("Clear drawing space") {
                    canvas.drawing = PKDrawing()
                }
                .foregroundColor(.red)
                Button("Exit") {
                    shown = false
                    if images.count >= 5 {
                        CharSets.add_characters_to_set(char: selection, images: images)
                    }
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

struct WritingView_Previews: PreviewProvider {
    static var previews: some View {
        WritingView(chars: "123456789-", selection: "1", shown: .constant(true))
    }
}

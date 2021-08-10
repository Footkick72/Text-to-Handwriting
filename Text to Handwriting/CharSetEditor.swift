//
//  FontEditor.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/15/21.
//

import Foundation
import SwiftUI
import PencilKit

struct CharSetEditor: View {
    @Binding var document: CharSetDocument
    @State var showingWritingView = false
    @State var currentLetter: String = ""
    @State var showingDeleteDataConfirmation = false
    @State var scale: CGFloat = 1.0
    @State var letterSpacing: Double = 4.0
    
    @Environment(\.colorScheme) var colorScheme
    
    let allchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890':,![(.?])\";-%@&+={}#$^*_/\\~<>"
    
    var body: some View {
        VStack {
            VStack {
                Slider(value: $letterSpacing, in: 0.0...20.0, step: 0.1, onEditingChanged: { _ in }, label: {})
                    .padding(.horizontal, 50)
                    .onChange(of: letterSpacing) { _ in
                        document.object.letterSpacing = Int(letterSpacing)
                    }
                    .onAppear() {
                        letterSpacing = Double(document.object.letterSpacing)
                    }
                Text("Character spacing")
                Slider(value: $document.object.forceMultiplier, in: 0.5...5.0, step: 0.1, onEditingChanged: { _ in }, label: {})
                    .padding(.horizontal, 50)
                Text("Character thickness")
            }
            let columns = [ GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),]
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach((0..<allchars.count), id: \.self) { i in
                        let set: CharSet = document.object
                        let char: String = String(allchars[i])
                        VStack {
                            if set.numberOfCharacters(char: char) != 0 {
                                let image = set.getSameImage(char: char)
                                Image(uiImage: image.image(from: CGRect(x: 0, y: 0, width: 256, height: 256), scale: 1.0))
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Text(char)
                            }
                        }
                        .frame(minWidth: 80, idealWidth: 360, maxWidth: 360, minHeight: 80, idealHeight: 360, maxHeight: 360)
                        .aspectRatio(1.0, contentMode: .fit)
                        .border(Color.black, width: 2)
                        .font(UIDevice.current.userInterfaceIdiom == .pad ? .title : .title2)
                        .background(
                            Rectangle()
                                .foregroundColor(getBackgroundColor(char: char))
                        )
                        .scaleEffect(scale)
                        .gesture(TapGesture()
                                    .onEnded({ _ in
                                        // This entire seemingly extraneous "scale" thing is to avoid some very weird behavior where the TapGesture.onEnded closure fails to save changes to the struct's state variables unless the view itself is dependant on those changes. As a result, I have the view be dependant on the @State variable scale, which is (technically) changed by the closure. No idea why and I don't really understand it, but this works for now.
                                        scale += 1.0
                                        scale = 1.0
                                        self.currentLetter = char
                                        self.showingWritingView = true
                                    })
                        )
                    }
                }
                .padding(10)
            }
            .sheet(isPresented: $showingWritingView) {
                WritingView(document: $document, chars: allchars, selection: currentLetter)
            }
            .navigationBarItems(trailing:
                                    Button("Erase character set data") {
                                        showingDeleteDataConfirmation = true
                                    }
                                    .foregroundColor(.red)
                                    .alert(isPresented: $showingDeleteDataConfirmation) {
                                        Alert(title: Text("Erase character set data"),
                                              message: Text("Are you sure you want to erase all of this character set's data?"),
                                              primaryButton: .destructive(Text("Erase data")) {
                                                document.object = CharSet(characters: Dictionary<String, Array<PKDrawing>>())
                                              },
                                              secondaryButton: .cancel())
                                    }
            )
        }
        .padding(20)
    }
    
    func getBackgroundColor(char: String) -> Color {
        if colorScheme == .light {
            if document.object.numberOfCharacters(char: char) == 0 {
                return Color(red: 1.0, green: 0.768, blue: 0.794, opacity: 1.0)
            } else if document.object.numberOfCharacters(char: char) < 5 {
                return Color(red: 1.0, green: 0.941, blue: 0.761, opacity: 1.0)
            } else {
                return Color(red: 0.761, green: 0.929, blue: 0.804, opacity: 1.0)
            }
        }
        else {
            if document.object.numberOfCharacters(char: char) == 0 {
                return Color(red: 0.803, green: 0.4, blue: 0.4, opacity: 1.0)
            } else if document.object.numberOfCharacters(char: char) < 5 {
                return Color(red: 0.803, green: 0.803, blue: 0.215, opacity: 1.0)
            } else {
                return Color(red: 0.372, green: 0.647, blue: 0.352, opacity: 1.0)
            }
        }
    }
}

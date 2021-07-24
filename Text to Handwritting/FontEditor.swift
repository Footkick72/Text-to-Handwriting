//
//  FontEditor.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/15/21.
//

import Foundation
import SwiftUI

struct FontEditor: View {
    @Binding var document: CharSetDocument
    @State var showingWritingView = false
    @State var currentLetter: String = ""
    
    @State var scale: CGFloat = 1.0
    
    let allchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890':,![(.?])\";-%@&+={}#$^*_/\\~<>"
    
    var body: some View {
        //[ GridItem(.adaptive(minimum: 120, maximum: 360), spacing: 20) ]
        let columns = [ GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                        GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                        GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                        GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),]
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach((0..<allchars.count), id: \.self) { i in
                    let set: CharSet = document.charset
                    let char: String = String(allchars[i])
                    VStack {
                        Text(char)
                        if set.numberOfCharacters(char: char) != 0 {
                            Image(uiImage: set.getSameImage(char: char))
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(minWidth: 80, idealWidth: 360, maxWidth: 360, minHeight: 80, idealHeight: 360, maxHeight: 360)
                    .aspectRatio(1.0, contentMode: .fit)
                    .border(Color.black, width: 2)
                    .font(UIDevice.current.userInterfaceIdiom == .pad ? .title : .title2)
                    .overlay(
                        Rectangle()
                            .foregroundColor(set.numberOfCharacters(char: char) == 0 ? .red : set.numberOfCharacters(char: char) < 5 ? .yellow : .green)
                            .opacity(0.2)
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
            WritingView(document: $document, chars: allchars, selection: currentLetter, shown: $showingWritingView, images: document.charset.getImages(char: currentLetter))
        }
    }
}

//
//  FontEditor.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/15/21.
//

import Foundation
import SwiftUI

struct FontEditor: View {
    @ObservedObject var sets = CharSets
    @State var showingWritingView = false
    @State var currentLetter: String = ""
    @State var setName: String = CharSets.getSet().name
    
    @State var scale: CGFloat = 1.0
    
    let allchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz’‘':,![(.?])\"”;1234567890-"
    
    var body: some View {
        let columns: [GridItem] = Array(repeating: GridItem.init(.flexible(), spacing: 20), count: 6)
        VStack {
            TextField("Character Set Name", text: $setName)
                .frame(width: 200)
                .multilineTextAlignment(.center)
                .autocapitalization(.none)
                .onChange(of: setName) { name in
                    sets.renameSet(name: name)
                }
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns) {
                    ForEach((0..<allchars.count), id: \.self) { i in
                        let set: CharSet = sets.getSet()
                        let char: String = String(allchars[i])
                        VStack {
                            Text(char)
                            if set.numberOfCharacters(char: char) != 0 {
                                Image(uiImage: set.getSameImage(char: char))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 40)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .padding(CGFloat(10))
                        .border(Color.black, width: 2)
                        .font(.title2)
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
            }
            .scaleEffect(CGFloat(0.8))
        }
        .sheet(isPresented: $showingWritingView) {
            WritingView(chars: allchars, selection: currentLetter, shown: $showingWritingView, images: sets.getSet().getImages(char: currentLetter))
        }
    }
}

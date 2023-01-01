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
    @State var showingAddCharsView = false
    @State var selecting = false
    @State var selectedChars: String = ""
    @State var scale: CGFloat = 1.0
    @State var letterSpacing: Double = 4.0
    @State var charBoxes: Dictionary<String,CGRect> = [:]
    @State var bulkSelectionInProgress: String = ""
    @State var bulkSelectionInProgressIsActivating = false
    
    @Environment(\.colorScheme) var colorScheme
    
//    let allchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890':,![(.?])\";-%@&+={}#$^*_/\\~<>"
    
    var body: some View {
        VStack {
            if selecting {
                Button(action: {
                    showingDeleteDataConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(selectedChars.count == 0 ? .gray : .red)
                        .font(.title2)
                }
                .disabled(selectedChars.count == 0)
                .alert(isPresented: $showingDeleteDataConfirmation) {
                    Alert(title: Text("Erase selected characters"),
                          message: Text("Are you sure you want to erase \(selectedChars.count) \(selectedChars.count == 1 ? "character" : "characters") from this character set?"),
                          primaryButton: .destructive(Text("Erase data")) {
                            document.object.removeChars(chars: selectedChars)
                            selectedChars = ""
                            selecting = false
                          },
                          secondaryButton: .cancel())
                }
            } else {
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
            }
            
            let columns = [ GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10),]
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach((0..<document.object.available_chars.count), id: \.self) { i in
                        let set: CharSet = document.object
                        let char: String = String(document.object.available_chars[i])
                        GeometryReader { reader in
                            VStack {
                                if set.numberOfCharacters(char: char) != 0 {
                                    let image = set.getSameImage(char: char)
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    Text(char)
                                        .frame(width: reader.size.width, height: reader.size.height, alignment: .center)
                                }
                            }
                            .onChange(of: reader.frame(in: .global)) { _ in
                                charBoxes[char] = reader.frame(in: .named("LazyVGrid"))
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
                                
                                if selecting {
                                    if selectedChars.contains(char) {
                                        selectedChars.remove(at: selectedChars.firstIndex(of: char.first!)!)
                                    } else {
                                        selectedChars.append(char)
                                    }
                                } else {
                                    self.currentLetter = char
                                    self.showingWritingView = true
                                }
                            })
                        )
                        .overlay(
                            alignment: .bottomTrailing
                        ) {
                            if selecting && (
                                (bulkSelectionInProgress.contains(char) && bulkSelectionInProgressIsActivating) ||
                                (selectedChars.contains(char) && (bulkSelectionInProgressIsActivating || !bulkSelectionInProgress.contains(char)))
                                )
                            {
                                Color.white
                                    .opacity(0.2)
                                    .allowsHitTesting(false)
                            }
                        }
                        .overlay(
                            alignment: .bottomTrailing
                        ) {
                            if selecting && (
                                (bulkSelectionInProgress.contains(char) && bulkSelectionInProgressIsActivating) ||
                                (selectedChars.contains(char) && (bulkSelectionInProgressIsActivating || !bulkSelectionInProgress.contains(char)))
                                )
                            {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding(2)
                                    .allowsHitTesting(false)
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.white)
                                    .padding(2)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    if !selecting {
                        Button(action: {
                            showingAddCharsView = true
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(minWidth: 80, idealWidth: 360, maxWidth: 360, minHeight: 80, idealHeight: 360, maxHeight: 360)
                                .aspectRatio(1.0, contentMode: .fit)
                                .border(Color.black, width: 2)
                                .background(
                                    Rectangle()
                                        .foregroundColor(.blue)
                                )
                        }
                    }
                }
                .padding(10)
                .gesture(
                    DragGesture()
                        .onChanged() { info in
                            if selecting {
                                var endchar: Character = " ".first!
                                var startchar: Character = " ".first!
                                for char in document.object.available_chars {
                                    let c = String(char)
                                    let box = charBoxes[c] ?? CGRect.zero
                                    if box.contains(info.location) {
                                        endchar = char
                                    }
                                    if box.contains(info.startLocation) {
                                        startchar = char
                                        bulkSelectionInProgressIsActivating = !selectedChars.contains(char)
                                    }
                                }
                                let start = document.object.available_chars.firstIndex(of: startchar)
                                let end = document.object.available_chars.firstIndex(of: endchar)
                                if let start = start, let end = end {
                                    bulkSelectionInProgress = String(document.object.available_chars[min(start,end)...max(start,end)])
                                }
                            }
                        }
                        .onEnded() { _ in
                            for char in bulkSelectionInProgress {
                                if bulkSelectionInProgressIsActivating {
                                    if !selectedChars.contains(char) {
                                        selectedChars.append(char)
                                    }
                                } else {
                                    if selectedChars.contains(char) {
                                        selectedChars.remove(at: selectedChars.firstIndex(of: char)!)
                                    }
                                }
                            }
                            bulkSelectionInProgress = ""
                        }
                )
                .coordinateSpace(name: "LazyVGrid")
            }
            .sheet(isPresented: $showingWritingView) {
                WritingView(document: $document, chars: document.object.available_chars, selection: currentLetter)
            }
            .sheet(isPresented: $showingAddCharsView) {
                AddCharsView(document: $document, showAddView: $showingAddCharsView)
            }
            .navigationBarItems(trailing:
                                    Button(selecting ? "Cancel" : "Select") {
                                        bulkSelectionInProgress = ""
                                        if selecting {
                                            selectedChars = ""
                                        }
                                        selecting.toggle()
                                    }
                                    .font(.body)
            )
        }
        .animation(.spring(), value: selecting)
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

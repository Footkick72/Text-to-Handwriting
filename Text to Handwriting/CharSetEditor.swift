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
    @State var memoizedDisplayImages: Dictionary<String,UIImage> = [:]
    @State var randomBooleanToForceButtonUpdate = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if selecting {
                HStack {
                    Button(action: {
                        showingDeleteDataConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .font(.title2)
                    }
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
                    Spacer()
                    Button(action: {
                        for char in selectedChars {
                            let c = String(char)
                            var new: Array<PKDrawing> = []
                            if let ims = document.object.characters[c] {
                                for o in ims {
                                    new.append(o.thickened(factor: 1.1))
                                }
                            }
                            document.object.characters[c] = new
                            memoizedDisplayImages[c] = document.object.getSameImage(char: c)
                        }
                    }) {
                        Image(systemName:"pencil.tip.crop.circle.badge.plus")
                            .font(.title2)
                    }
                    Spacer()
                    Button(action: {
                        for char in selectedChars {
                            let c = String(char)
                            var new: Array<PKDrawing> = []
                            if let ims = document.object.characters[c] {
                                for o in ims {
                                    new.append(o.thickened(factor: 1.0/1.1))
                                }
                            }
                            document.object.characters[c] = new
                            memoizedDisplayImages[c] = document.object.getSameImage(char: c)
                        }
                    }) {
                        Image(systemName:"pencil.tip.crop.circle.badge.minus")
                            .font(.title2)
                    }
                    Spacer()
                    Button(action: {
                        do {
                            randomBooleanToForceButtonUpdate.toggle()
                            let imagesForChars = (0..<selectedChars.count)
                                .map({
                                    document.object.getDrawings(char: String(selectedChars[$0]))
                                })
                            var imagesDict: Dictionary<String,Array<PKDrawing>> = [:]
                            for (i,c) in selectedChars.enumerated() {
                                imagesDict[String(c)] = imagesForChars[i]
                            }
                            let data = try JSONEncoder().encode(imagesDict)
                            let pasteboard = UIPasteboard(name: .t2h, create: true)!
                            pasteboard.setData(data, forPasteboardType: "org.davidlong.t2hc")
                        } catch {
                            print(error)
                        }
                    }) {
                        HStack{
                            Image(systemName: "doc.on.doc")
                                .font(.title2)
                            Text("Copy")
                        }
                    }
                }
                .disabled(selectedChars.count == 0)
                .foregroundColor(selectedChars.count == 0 ? .gray : .blue)
                .padding(.horizontal, 20)
            } else {
                if let data = UIPasteboard(name: .t2h, create: true)!.data(forPasteboardType: "org.davidlong.t2hc") {
                    Button(action: {
                        do {
                            let imagesDict = try JSONDecoder().decode(Dictionary<String,Array<PKDrawing>>.self, from: data)
                            for (c,images) in imagesDict {
                                if !document.object.available_chars.contains(c) {
                                    document.object.addChars(chars: c)
                                }
                                document.object.characters[c] = images
                                memoizedDisplayImages[c] = document.object.getSameImage(char: c)
                            }
                        } catch {
                            print(error)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .font(.title2)
                            Text("Paste")
                        }
                        .scaleEffect(randomBooleanToForceButtonUpdate ? 1 : 1.001) // force this button to update
                    }
                }
                
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
                        .onChange(of: document.object.forceMultiplier) { _ in
                            for char in document.object.available_chars {
                                memoizedDisplayImages[String(char)] = document.object.getSameImage(char: String(char))
                            }
                        }
                    Text("Character thickness")
                }
            }
            
            GeometryReader { outerreader in
                let columns = Array(repeating: GridItem(.flexible(minimum: 80, maximum: 360), spacing: 10), count: Int(outerreader.size.width / 120))
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach((0..<document.object.available_chars.count), id: \.self) { i in
                            let set: CharSet = document.object
                            let char: String = String(document.object.available_chars[i])
                            GeometryReader { reader in
                                VStack {
                                    if set.numberOfCharacters(char: char) != 0 {
                                        Image(uiImage: getDisplayImageForChar(char: char))
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
                            .sheet(isPresented: $showingAddCharsView) {
                                AddCharsView(document: $document, showAddView: $showingAddCharsView)
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
            }
            .onAppear() {
                for char in document.object.available_chars {
                    memoizedDisplayImages[String(char)] = document.object.getSameImage(char: String(char))
                }
            }
            .sheet(isPresented: $showingWritingView) {
                WritingView(document: $document, memoizedDisplayImages: $memoizedDisplayImages, chars: document.object.available_chars, selection: currentLetter)
                    .onDisappear() {
                        for char in document.object.available_chars {
                            memoizedDisplayImages[String(char)] = document.object.getSameImage(char: String(char))
                        }
                    }
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
    
    func getDisplayImageForChar(char: String) -> UIImage {
        var image: UIImage? = nil
        if let im = memoizedDisplayImages[char] {
            image = im
        } else {
            image = document.object.getSameImage(char: char)
        }
        return image!
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

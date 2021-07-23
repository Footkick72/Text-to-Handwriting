//
//  FontSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct FontSelector: View {
    @State var showingSelector = false
    @State var showingUniquenessAlert = false
    @ObservedObject var charsets = CharSets
    
    private var itemWidth: CGFloat = 150
    
    var body: some View {
        Button("Create new character set") {
            do {
                var name = "Untitled"
                var i = 0
                while FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".charset").path) {
                    i += 1
                    name = "Untitled " + String(i)
                }
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".charset")
                let set = CharSetDocument(name: "Untitled", characters: Dictionary<String, Array<Data>>(), charlens: Dictionary<String, Float>()).charset
                let data = try JSONEncoder().encode(set)
                try data.write(to: path)
            } catch { print(error) }
            //TODO: open the new document, if possible
        }
        Button("Import character set") {
            showingSelector = true
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(charsets.documents, id: \.self) { file in
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    let set = CharSetDocument(from: FileManager.default.contents(atPath: path.path)!)
                    VStack {
                        Text(verbatim: set.charset.name)
                            .foregroundColor(charsets.document?.charset == set.charset ? .red : .black)
                        if let preview = set.charset.get_preview() {
                            Image(uiImage: preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black, width: 1)
                                .overlay(
                                    Button(action: {
                                        charsets.documents.remove(at: charsets.documents.firstIndex(of: file)!)
                                    }) {
                                        Image(systemName: "xmark.circle")
                                            .padding(4)
                                    }
                                    .foregroundColor(.red)
                                    ,alignment: .topTrailing)
                        }
                    }
                    .gesture(TapGesture().onEnded({ charsets.document = set }))
                    .frame(width: itemWidth)
                }
            }
        }
        .frame(width: max(0, min(CGFloat(charsets.documents.count) * itemWidth + CGFloat(charsets.documents.count - 1) * 10, CGFloat(itemWidth * 3 + 10 * 2))), alignment: .center)
        .fileImporter(isPresented: $showingSelector, allowedContentTypes: [.charSetDocument]) { url in
            do {
                let data = try FileManager.default.contents(atPath: url.get().path)
                let document = CharSetDocument(from: data!)
                
                var isUnique = true
                for file in charsets.documents {
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    let set = CharSetDocument(from: FileManager.default.contents(atPath: path.path)!)
                    if set.charset == document.charset {
                        isUnique = false
                    }
                }
                
                if isUnique {
                    charsets.document = document
                    charsets.documents.append(try url.get().lastPathComponent)
                } else {
                    showingUniquenessAlert = true
                }
                
            } catch {}
        }
        .alert(isPresented: $showingUniquenessAlert) {
            Alert(title: Text("Cannot load charset"), message: Text("You have already loaded an identical charset"), dismissButton: .cancel())
        }
    }
}

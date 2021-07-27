//
//  DocumentSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/26/21.
//

import Foundation
import SwiftUI

typealias TemplateSelector = DocumentSelector<TemplateDocument>
typealias CharSetSelector = DocumentSelector<CharSetDocument>

struct DocumentSelector<DocType: HandwritingDocument>: View {
    @State var showingSelector = false
    @State var showingUniquenessAlert = false
    @State var textToGenerate: String
    @ObservedObject var objectCatalog: Catalog<DocType>
    
    var itemWidth: CGFloat = 150
    
    var body: some View {
        HStack {
            Button(action: {
                showingSelector = true
            }) {
                Image(systemName: "square.and.arrow.down")
            }
            .alert(isPresented: $showingUniquenessAlert) {
                Alert(title: Text("Cannot load charset"), message: Text("You have already loaded an identical charset"), dismissButton: .default(Text("OK")))
            }
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(objectCatalog.documents, id: \.self) { file in
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    if FileManager.default.fileExists(atPath: path.path) {
                        let set = DocType(from: FileManager.default.contents(atPath: path.path)!)
                        VStack {
                            HStack {
                                Text(file.removeExtension(DocType.fileExtension))
                                    .foregroundColor(objectCatalog.isSelectedDocument(fileNamed: file) ? .red : .black)
                                Button(action: {
                                    objectCatalog.deleteObject(fileNamed: file)
                                }) {
                                    Image(systemName: "xmark.circle")
                                }
                                .foregroundColor(.red)
                            }
                            Image(uiImage: set.object.getPreview())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black, width: 1)
                        }
                        .overlay(
                            Text(set.object.isCompleteFor(text: textToGenerate) ? "" : "Warning:\nCharset\nis incomplete\nfor text!")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .background(
                                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                        .foregroundColor(.white)
                                        .opacity(set.object.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
                                )
                        )
                        .gesture(TapGesture().onEnded({ objectCatalog.documentPath = file }))
                        .frame(width: itemWidth)
                    }
                }
            }
        }
        .frame(width: max(0, min(CGFloat(objectCatalog.documents.count) * itemWidth + CGFloat(objectCatalog.documents.count - 1) * 10, CGFloat(itemWidth * 2 + 10))), alignment: .center)
        .fileImporter(isPresented: $showingSelector, allowedContentTypes: [DocType.fileType]) { url in
            do {
                let data = try FileManager.default.contents(atPath: url.get().path)
                let document = DocType(from: data!)

                var isUnique = true
                for file in objectCatalog.documents {
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    let set = DocType(from: FileManager.default.contents(atPath: path.path)!)
                    if set.object == document.object {
                        isUnique = false
                    }
                }

                if isUnique {
                    objectCatalog.documentPath = try url.get().lastPathComponent
                    objectCatalog.documents.append(try url.get().lastPathComponent)
                } else {
                    showingUniquenessAlert = true
                }

            } catch {}
        }
        .onAppear() {
            objectCatalog.trim()
        }
    }
}


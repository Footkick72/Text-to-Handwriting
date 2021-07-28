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
    @State var title: Text
    @State var showingSelector = false
    @State var showingUniquenessAlert = false
    @State var textToGenerate: String
    @ObservedObject var objectCatalog: Catalog<DocType>
    
    var itemWidth: CGFloat = 200
    
    var body: some View {
        VStack {
            title
            if objectCatalog.documentPath != nil {
                Text(verbatim: objectCatalog.documentPath!.lastPathComponent.removeExtension(DocType.fileExtension))
                Image(uiImage: objectCatalog.document()!.object.getPreview())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: itemWidth)
                    .border(Color.black, width: 1)
                    .overlay(
                        Text(objectCatalog.document()!.object.isCompleteFor(text: textToGenerate) ? "" : "Warning: Charset is incomplete for text!")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                    .foregroundColor(.white)
                                    .opacity(objectCatalog.document()!.object.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
                            )
                    )
            }
        }
        .onTapGesture {
            showingSelector = true
        }
        .popover(isPresented: $showingSelector) {
            UserFilesView<DocType>(showingSelector: $showingSelector, textToGenerate: textToGenerate, objectCatalog: objectCatalog)
            .padding()
        }
    }
}

struct UserFilesView<DocType: HandwritingDocument>: View {
    @Binding var showingSelector: Bool
    @State var showingImporter = false
    @State var showingUniquenessAlert = false
    @State var textToGenerate: String
    @ObservedObject var objectCatalog: Catalog<DocType>
    
    var itemWidth: CGFloat = 200
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            let columns = [ GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),]
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(Array(DocType.defaults.keys), id: \.self) { key in
                    let set = DocType.defaults[key]
                    VStack {
                        Text(verbatim: key.lastPathComponent.removeExtension(DocType.fileExtension))
                            .font(.subheadline)
                        Image(uiImage: set!.getPreview())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: itemWidth)
                            .border(Color.black, width: 1)
                            .overlay(
                                Text(set!.isCompleteFor(text: textToGenerate) ? "" : "Warning: Charset is incomplete for text!")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                            .foregroundColor(.white)
                                            .opacity(set!.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
                                    )
                            )
                    }
                    .padding()
                    .border(Color.black, width: objectCatalog.isSelectedDocument(set!) ? 1 : 0)
                    .onTapGesture() {
                        objectCatalog.documentPath = key
                        showingSelector = false
                    }
                }
                ForEach(0..<objectCatalog.documents.count, id: \.self) { i in
                    let set = DocType(from: FileManager.default.contents(atPath: objectCatalog.documents[i].path)!)
                    VStack {
                        HStack {
                            Text(verbatim: objectCatalog.documents[i].lastPathComponent.removeExtension(DocType.fileExtension))
                                .font(.subheadline)
                            Button(action: {
                                objectCatalog.deleteObject(at: i)
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                            .foregroundColor(.red)
                        }
                        Image(uiImage: set.object.getPreview())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: itemWidth)
                            .border(Color.black, width: 1)
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
                    }
                    .padding()
                    .border(Color.black, width: objectCatalog.isSelectedDocument(at: i) ? 1 : 0)
                    .onTapGesture {
                        objectCatalog.documentPath = objectCatalog.documents[i]
                        showingSelector = false
                    }
                }
                VStack(spacing: 12.5) {
                    Text("Import")
                        .foregroundColor(.blue)
                    Button(action: {
                        showingImporter = true
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .alert(isPresented: $showingUniquenessAlert) {
                        Alert(title: Text("Cannot load charset"), message: Text("You have already loaded an identical charset"), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [DocType.fileType]) { url in
                do {
                    let data = try FileManager.default.contents(atPath: url.get().path)
                    let document = DocType(from: data!)
                    
                    var isUnique = true
                    for file in objectCatalog.documents {
                        let set = DocType(from: FileManager.default.contents(atPath: file.path)!)
                        if set.object == document.object {
                            isUnique = false
                        }
                    }
                    
                    if isUnique {
                        objectCatalog.documents.append(try url.get())
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

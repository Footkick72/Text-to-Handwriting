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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            title
            if let path = objectCatalog.documentPath, let object = objectCatalog.document()?.object {
                Text(verbatim: path.lastPathComponent.removeExtension(DocType.fileExtension))
                Image(uiImage: object.getPreview())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: itemWidth)
                    .border(Color.black, width: 1)
                    .overlay(
                        Text(object.isCompleteFor(text: textToGenerate) ? "" : "Warning: Charset is incomplete for text!")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .background(
                                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                    .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
                                    .opacity(object.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            let columns = [ GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),
                            GridItem(.flexible(minimum: itemWidth, maximum: 360), spacing: 10),]
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(Array(DocType.defaults.keys).sorted(by: {a, b in
                    return a.lastPathComponent < b.lastPathComponent
                }), id: \.self) { key in
                    if let set = DocType.defaults[key] {
                        VStack {
                            Text(verbatim: key.lastPathComponent.removeExtension(DocType.fileExtension))
                                .font(.subheadline)
                            Image(uiImage: set.getPreview())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: itemWidth)
                                .border(Color.black, width: 1)
                                .overlay(
                                    Text(set.isCompleteFor(text: textToGenerate) ? "" : "Warning: Charset is incomplete for text!")
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                                                .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
                                                .opacity(set.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
                                        )
                                )
                        }
                        .padding()
                        .border(Color.black, width: objectCatalog.isSelectedDocument(path: key) ? 1 : 0)
                        .onTapGesture() {
                            objectCatalog.documentPath = key
                            objectCatalog.save()
                            showingSelector = false
                        }
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
                                            .foregroundColor(colorScheme == .light ? .white : Color(.sRGB, red: 27.0/255.0, green: 27.0/255.0, blue: 28.0/255.0, opacity: 1.0))
                                            .opacity(set.object.isCompleteFor(text: textToGenerate) ? 0.0 : 1.0)
                                    )
                            )
                    }
                    .padding()
                    .border(Color.black, width: objectCatalog.isSelectedDocument(path: objectCatalog.documents[i]) ? 1 : 0)
                    .onTapGesture {
                        objectCatalog.documentPath = objectCatalog.documents[i]
                        objectCatalog.save()
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
                        Alert(title: Text("Cannot load file"), message: Text("You have already loaded this file"), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [DocType.fileType]) { url in
                do {
                    if objectCatalog.documents.firstIndex(of: try url.get()) == nil {
                        objectCatalog.documents.append(try url.get())
                        objectCatalog.save()
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

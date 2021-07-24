//
//  TemplateSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct TemplateSelector: View {
    @State var showingSelector = false
    @State var showingUniquenessAlert = false
    @ObservedObject var templates = Templates
    
    private var itemWidth: CGFloat = 150
    
    var body: some View {
        Button("Create new template") {
            do {
                var name = "Untitled"
                var i = 0
                while FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".tthtemplate").path) {
                    i += 1
                    name = "Untitled " + String(i)
                }
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".tthtemplate")
                let t = TemplateDocument().template
                let data = try JSONEncoder().encode(t)
                try data.write(to: path)
            } catch { print(error) }
            //TODO: open the new document, if possible
        }
        Button("Import template") {
            showingSelector = true
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10) {
                ForEach(templates.documents, id: \.self) { file in
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    if FileManager.default.fileExists(atPath: path.path) {
                        let template = TemplateDocument(from: FileManager.default.contents(atPath: path.path)!)
                        VStack {
                            Text(file.removeExtention(".tthtemplate"))
                                .foregroundColor(templates.document?.template == template.template ? .red : .black)
                            Image(uiImage: template.template.getBackground())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black, width: 1)
                        }
                        .overlay(
                            Button(action: {
                                templates.documents.remove(at: templates.documents.firstIndex(of: file)!)
                            }) {
                                Image(systemName: "xmark.circle")
                            }
                            .foregroundColor(.red)
                            ,alignment: .topTrailing)
                        .gesture(TapGesture().onEnded({ templates.document = template }))
                        .frame(width: itemWidth)
                    }
                }
            }
        }
        .frame(width: max(0, min(CGFloat(templates.documents.count) * itemWidth + CGFloat(templates.documents.count - 1) * 10, CGFloat(itemWidth * 3 + 10 * 2))), alignment: .center)
        .fileImporter(isPresented: $showingSelector, allowedContentTypes: [.templateDocument]) { url in
            do {
                let data = try FileManager.default.contents(atPath: url.get().path)
                let document = TemplateDocument(from: data!)

                var isUnique = true
                for file in templates.documents {
                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
                    let template = TemplateDocument(from: FileManager.default.contents(atPath: path.path)!)
                    if template.template == document.template {
                        isUnique = false
                    }
                }

                if isUnique {
                    templates.document = document
                    templates.documents.append(try url.get().lastPathComponent)
                } else {
                    showingUniquenessAlert = true
                }

            } catch {}
        }
        .alert(isPresented: $showingUniquenessAlert) {
            Alert(title: Text("Cannot load template"), message: Text("You have already loaded an identical template"), dismissButton: .cancel())
        }
        .onAppear() {
            templates.trimTemplates()
        }
    }
}

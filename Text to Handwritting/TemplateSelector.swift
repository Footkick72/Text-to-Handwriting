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
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(alignment: .center, spacing: 10) {
//                ForEach(templates.documents, id: \.self) { file in
//                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
//                    let set = CharSetDocument(from: FileManager.default.contents(atPath: path.path)!)
//                    VStack {
//                        Text(file.removeExtention(".charset"))
//                            .foregroundColor(charsets.document?.charset == set.charset ? .red : .black)
//                        Image(uiImage: set.charset.get_preview())
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .border(Color.black, width: 1)
//                    }
//                    .overlay(
//                        Button(action: {
//                            charsets.documents.remove(at: charsets.documents.firstIndex(of: file)!)
//                        }) {
//                            Image(systemName: "xmark.circle")
//                        }
//                        .foregroundColor(.red)
//                        ,alignment: .topTrailing)
//                    .gesture(TapGesture().onEnded({ charsets.document = set }))
//                    .frame(width: itemWidth)
//                }
//            }
//        }
//        .frame(width: max(0, min(CGFloat(charsets.documents.count) * itemWidth + CGFloat(charsets.documents.count - 1) * 10, CGFloat(itemWidth * 3 + 10 * 2))), alignment: .center)
//        .fileImporter(isPresented: $showingSelector, allowedContentTypes: [.charSetDocument]) { url in
//            do {
//                let data = try FileManager.default.contents(atPath: url.get().path)
//                let document = CharSetDocument(from: data!)
//
//                var isUnique = true
//                for file in charsets.documents {
//                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(file)
//                    let set = CharSetDocument(from: FileManager.default.contents(atPath: path.path)!)
//                    if set.charset == document.charset {
//                        isUnique = false
//                    }
//                }
//
//                if isUnique {
//                    charsets.document = document
//                    charsets.documents.append(try url.get().lastPathComponent)
//                } else {
//                    showingUniquenessAlert = true
//                }
//
//            } catch {}
//        }
//        .alert(isPresented: $showingUniquenessAlert) {
//            Alert(title: Text("Cannot load charset"), message: Text("You have already loaded an identical charset"), dismissButton: .cancel())
//        }
    }
}

//
//struct TemplateSelector: View {
//    @ObservedObject var templates = Templates
//    private var item_width: CGFloat = 150
//    var body: some View {
//        VStack(alignment: .center, spacing: 30) {
//            VStack(alignment: .center, spacing: 10) {
//                Button("Add template") {
//
//                }
//            }
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(alignment: .center, spacing: 10) {
//                    ForEach(Array(Templates.templates.keys), id: \.self) { option in
//                        VStack(alignment: .center, spacing: 5) {
//                            Text(option)
//                            Image(uiImage: Templates.templates[option]!.get_bg())
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .border(Color.black)
//                                .frame(width: item_width)
//                                .tag(option)
//                        }
//                        .foregroundColor(templates.primaryTemplate == option ? .red : .black)
//                        .gesture(TapGesture().onEnded({ templates.primaryTemplate = option }))
//                    }
//                }
//            }.frame(width: max(0, min(CGFloat(templates.templates.count) * item_width + CGFloat(templates.templates.count - 1) * 10, CGFloat(item_width * 3 + 10 * 2))), alignment: .center)
//        }
//
//        .sheet(item: $templateViewState) { item in
//            switch item {
//            case .Creation:
//                TemplateCreator(shown: $templateViewState)
//            case .Editing:
//                TemplateEditor(shown: $templateViewState)
//            }
//        }
//        .alert(isPresented: $showingTemplateDeletionConfirmation) {
//            Alert(title: Text("Delete Template"),
//                  message: Text("Are you sure you want to delete template \"" + templates.get_template().name + "\"?"),
//                  primaryButton: .destructive(Text("Yes")) {
//                    templates.deleteTemplate()
//                  },
//                  secondaryButton: .cancel())
//        }
//    }
//}

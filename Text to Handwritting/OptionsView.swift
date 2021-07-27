//
//  OptionsView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

//struct OptionsView: View {
//    @Binding var document: Text_to_HandwritingDocument
//    @Binding var shown: Bool
//
//    var body: some View {
//        VStack {
//            testView()
//            testView()
//        }
//    }
//}
//
//struct testView: View {
//    @State var showingAlert1 = false
//    @State var showingAlert2 = false
//    @State var showingSelector = false
//
//    var body: some View {
//        HStack {
//            Button(action: {
//                var name = "Untitled"
//                var i = 0
//                while FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".tthcharset").path) {
//                    i += 1
//                    name = "Untitled " + String(i)
//                }
//                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name + ".tthcharset")
//                showingAlert1 = true
//            }) {
//                Image(systemName: "doc.badge.plus")
//            }
//            .alert(isPresented: $showingAlert1) {
//                Alert(title: Text("File created"), message: Text("The file has been created and added to your filesystem"), dismissButton: .default(Text("OK")))
//            }
//
//            Button(action: {
//                showingAlert2 = true
//            }) {
//                Image(systemName: "square.and.arrow.down")
//            }
//            .alert(isPresented: $showingAlert2) {
//                Alert(title: Text("Cannot load file"), message: Text("You have already loaded an identical file"), dismissButton: .default(Text("OK")))
//            }
//        }
//        ScrollView(.horizontal) {
//            HStack(alignment: .center) {
//                ForEach(0..<100) {
//                    Text("Row \($0)")
//                }
//            }
//        }
//        .fileImporter(isPresented: $showingSelector, allowedContentTypes: [.charSetDocument]) { url in }
//    }
//}

struct OptionsView: View {
    @ObservedObject var charsets = CharSets
    @ObservedObject var templates = Templates
    @Binding var document: Text_to_HandwritingDocument
    @Binding var shown: Bool
    @State var generationProgress: Double = 0
    @State var generating = false
    @State var finished = false

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                VStack(alignment: .center, spacing: 20) {
                    CharSetSelector(title: Text("Choose Font:"), textToGenerate: document.text, objectCatalog: charsets)
                }
                VStack(alignment: .center, spacing: 20) {
                    TemplateSelector(title: Text("Choose template:"), textToGenerate: document.text, objectCatalog: templates)
                }
                HStack(alignment: .center, spacing: 50) {
                    Button("Save to Photos") {
                        DispatchQueue.global(qos: .userInitiated).async {
                            document.createImage(charset: charsets.document()!.object, template: templates.document()!.object, updateProgress: { value, going, done in
                                generationProgress = value
                                generating = going
                                finished = done
                            })
                        }
                    }
                    .disabled((charsets.document() == nil || templates.document() == nil) ? true : false)
                    .alert(isPresented: $finished) {
                        Alert(title: Text("Image saved to photos"), message: nil, dismissButton: .default(Text("Ok")) { shown = false })
                    }
                    Button("cancel") {
                        shown = false
                    }
                    .foregroundColor(.red)
                }
            }
            .blur(radius: generating ? 6 : 0)
            .animation(.spring())
            if generating {
                ProgressView("Generating...", value: generationProgress, total: 1.0)
                    .frame(width: 200)
                    .padding()
            }
        }
    }
}

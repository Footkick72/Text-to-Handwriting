//
//  OptionsView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct OptionsView: View {
    @ObservedObject var charsets = CharSets
    @ObservedObject var templates = Templates
    @Binding var document: Text_to_HandwrittingDocument
    @Binding var shown: Bool
    @State var generationProgress: Double = 0
    @State var generating = false
    @State var finished = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                VStack(alignment: .center, spacing: 20) {
                    Text("Font")
                    FontSelector(textToGenerate: document.text)
                }
                VStack(alignment: .center, spacing: 20) {
                    Text("Template")
                    TemplateSelector()
                }
                HStack(alignment: .center, spacing: 50) {
                    Button("generate") {
                        DispatchQueue.global(qos: .userInitiated).async {
                            document.createImage(charset: charsets.document()!.charset, template: templates.document()!.template, updateProgress: { value, going, done in
                                generationProgress = value
                                generating = going
                                finished = done
                            })
                        }
                    }
                    .disabled((charsets.document() == nil || templates.document() == nil) ? true : false)
                    Button("cancel") {
                        shown = false
                    }
                    .foregroundColor(.red)
                }
            }
            .alert(isPresented: $finished) {
                Alert(title: Text("Image saved to photos"), message: nil, dismissButton: .default(Text("Ok")))
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

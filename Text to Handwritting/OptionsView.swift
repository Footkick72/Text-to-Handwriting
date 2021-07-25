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
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                VStack(alignment: .center, spacing: 20) {
                    Text("Font")
                    FontSelector()
                }
                VStack(alignment: .center, spacing: 20) {
                    Text("Template")
                    TemplateSelector()
                }
                HStack(alignment: .center, spacing: 50) {
                    Button("generate") {
                        DispatchQueue.global(qos: .userInitiated).async {
                            document.createImage(charset: charsets.document()!.charset, template: templates.document()!.template, updateProgress: { value, going in
                                generationProgress = value
                                generating = going
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

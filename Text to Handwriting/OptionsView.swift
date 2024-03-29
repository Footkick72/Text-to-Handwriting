//
//  OptionsView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI
import StoreKit

struct OptionsView: View {
    @ObservedObject var charsets = CharSets
    @ObservedObject var templates = Templates
    @Binding var document: Text_to_HandwritingDocument
    @Binding var shown: Bool
    @State var generationProgress: Double = 0
    @State var generating = false
    @State var finished = false

    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            VStack(alignment: .center, spacing: 20) {
                CharSetSelector(title: Text("Choose character set"), textToGenerate: document.text, objectCatalog: charsets, disabled: $generating)
            }
            VStack(alignment: .center, spacing: 20) {
                TemplateSelector(title: Text("Choose template"), textToGenerate: document.text, objectCatalog: templates, disabled: $generating)
            }
            HStack(alignment: .center, spacing: 50) {
                Button("Save to photos") {
                    if !generating {
                        DispatchQueue.global(qos: .userInitiated).async {
                            document.createImage(charset: charsets.document()!.object, template: templates.document()!.object, updateProgress: { value, going, done in
                                generationProgress = value
                                generating = going
                                finished = done
                            })
                        }
                    }
                }
                .font(.headline)
                .disabled((charsets.document() == nil || templates.document() == nil) ? true : false)
                .alert(isPresented: $finished) {
                    Alert(title: Text("Image saved to photos").font(.body), message: nil, dismissButton: .default(Text("Ok")) {
                        shown = false
                        requestReview()
                    })
                }
                Button("Cancel") {
                    if !generating {
                        shown = false
                    }
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
        }
        .blur(radius: generating ? 6 : 0)
        .animation(.spring(), value: generating)
        if generating {
            ProgressView("Generating...", value: generationProgress, total: 1.0)
                .frame(width: 200)
                .padding()
        }
    }
    
    func requestReview() {
        if UserDefaults.standard.integer(forKey: "DocumentsGenerated") % 5 == 4 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        UserDefaults.standard.setValue(UserDefaults.standard.integer(forKey: "DocumentsGenerated") + 1, forKey: "DocumentsGenerated")
    }
}

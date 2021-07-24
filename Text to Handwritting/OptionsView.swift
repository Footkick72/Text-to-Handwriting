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
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            VStack(alignment: .center, spacing: 20) {
                Text("Font")
                FontSelector()
            }
            VStack(alignment: .center, spacing: 20) {
                Text("Paper")
                TemplateSelector()
            }
            HStack(alignment: .center, spacing: 50) {
                Button("generate") {
                    document.createImage(charset: charsets.document!.charset, template: templates.document!.template)
                }
                .disabled((charsets.document == nil || templates.document == nil) ? true : false)
                Button("cancel") {
                    shown = false
                }
                .foregroundColor(.red)
            }
        }
    }
}

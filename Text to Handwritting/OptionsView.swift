//
//  OptionsView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct OptionsView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @Binding var shown: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 200) {
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
                    document.createImage()
                }
                Button("cancel") {
                    shown = false
                }
                .foregroundColor(.red)
            }
        }
    }
}

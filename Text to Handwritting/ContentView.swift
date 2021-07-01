//
//  ContentView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Text_to_HandwrittingDocument

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center, spacing: 10) {
                Button("generate image", action: document.createImage)
            }
            TextEditor(text: $document.text)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Text_to_HandwrittingDocument()))
    }
}

//
//  ContentView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Text_to_HandwritingDocument
    @State private var showingGenerationOptions = false
    
    var body: some View {
        TextEditor(text: $document.text)
        .sheet(isPresented: $showingGenerationOptions) {
            OptionsView(document: $document, shown: $showingGenerationOptions)
        }
        .navigationBarItems(trailing:
                                Button("generate image") {
                                    showingGenerationOptions.toggle()
                                }
        )
    }
}

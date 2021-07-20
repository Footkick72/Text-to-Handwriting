//
//  ContentView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @State private var showingGenerationOptions = false
    
    var body: some View {
        VStack(alignment: .center) {
            TextEditor(text: $document.text)
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Text_to_HandwrittingDocument()))
    }
}

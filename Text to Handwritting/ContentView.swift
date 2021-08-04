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
        if document.corrupted {
            Text("File is corrupted, unable to read!")
        } else {
            TextEditor(text: $document.text)
            .sheet(isPresented: $showingGenerationOptions) {
                OptionsView(document: $document, shown: $showingGenerationOptions)
            }
            .navigationBarItems(trailing:
                                    Button("Convert to handwriting") {
                                        showingGenerationOptions.toggle()
                                    }
            )
        }
    }
}

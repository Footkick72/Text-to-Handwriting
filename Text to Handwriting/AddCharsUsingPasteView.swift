//
//  AddCharsUsingPasteView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 12/30/22.
//

import Foundation
import SwiftUI

struct AddCharsUsingPasteView: View {
    @Binding var document: CharSetDocument
    @Binding var showAddView: Bool
    @State var showingTextBox = false
    @State var text = ""
    
    var body: some View {
        Button(action: {
            showingTextBox = true
        }) {
            Text("Paste Text")
        }
        .padding(10)
        .sheet(isPresented: $showingTextBox) {
            VStack {
                TextField("Source Text", text: $text, axis: .vertical)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .border(.black)
                    .padding(50)
                Button(action: {
                    document.object.addChars(chars: text)
                    showingTextBox = false
                    showAddView = false
                }) {
                    Text("Add")
                }
            }
        }
    }
}

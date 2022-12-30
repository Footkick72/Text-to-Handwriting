//
//  AddCharsPreset.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 12/30/22.
//

import Foundation
import SwiftUI

struct AddCharsPreset: View {
    @Binding var document: CharSetDocument
    @Binding var showAddView: Bool
    @State var name: String
    @State var chars: String
    
    var body: some View {
        Button(action: {
            document.object.addChars(chars: chars)
            showAddView = false
        }) {
            HStack {
                Text(name)
            }
        }
        .padding(10)
    }
}

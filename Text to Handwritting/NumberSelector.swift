//
//  NumberSelector.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct NumberSelector: View {
    @Binding var value: Float
    @State var minValue: Float
    @State var maxValue: Float
    @State var label: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(label)
            Slider(value: $value,
                   in: minValue...maxValue,
                   step: 1.0,
                   onEditingChanged: {_ in },
                   minimumValueLabel: Text(String(Int(minValue))),
                   maximumValueLabel: Text(String(Int(maxValue))),
                   label: {})
            Text(String(Int(value)))
        }
    }
}

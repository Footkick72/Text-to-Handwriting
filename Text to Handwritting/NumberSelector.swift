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
    
    let rounded: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(label)
            Slider(value: $value,
                   in: minValue...maxValue,
                   step: 0.01,
                   onEditingChanged: {_ in },
                   minimumValueLabel: Text(String(rounded ? Float(Int(minValue)) : round(minValue * 100) / 100)),
                   maximumValueLabel: Text(String(rounded ? Float(Int(maxValue)) : round(maxValue * 100) / 100)),
                   label: {})
            Text(String(rounded ? Float(Int(value)) : round(value * 100) / 100))
        }
    }
}

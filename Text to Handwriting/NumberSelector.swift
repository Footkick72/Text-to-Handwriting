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
    @State var internalValue: Float = 0
    @State var minValue: Float
    @State var maxValue: Float
    @State var label: String
    @State var displayValue: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(label)
            Slider(value: $internalValue,
                   in: log2(minValue) ... log2(maxValue),
                   step: 0.00001,
                   onEditingChanged: {_ in },
                   minimumValueLabel: Text(String(minValue)),
                   maximumValueLabel: Text(String(maxValue)),
                   label: {})
                .onChange(of: internalValue) { v in
                    value = exp2(v)
                }
                .onAppear() {
                    internalValue = log2(value)
                }
            Text(String(round(value * 100) / 100))
        }
    }
}

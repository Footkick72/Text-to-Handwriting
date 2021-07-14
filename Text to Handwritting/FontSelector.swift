//
//  FontSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct FontSelector: View {
    @State private var selectedFont = CharSets.primary_set
    private var item_width = CGFloat(150)
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(CharSets.sets.keys), id: \.self) { option in
                    Text(option)
                        .foregroundColor(selectedFont == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ CharSets.primary_set = option; selectedFont = option}))
                        .frame(width: item_width, height: 50)
                        .border(Color.black, width: 2)
                }
            }
        }.frame(width: min(CGFloat(CharSets.sets.count) * item_width, CGFloat(item_width * 4)), alignment: .center)
    }
}

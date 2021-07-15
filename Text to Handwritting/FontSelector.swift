//
//  FontSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct FontSelector: View {
    @ObservedObject var sets = CharSets
    @State var showingCharSetCreator = false
    private var item_width = CGFloat(150)
    var body: some View {
        Button("Create new character set") {
            showingCharSetCreator = true
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(CharSets.sets.keys), id: \.self) { option in
                    Text(option)
                        .foregroundColor(sets.primary_set == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ sets.primary_set = option }))
                        .frame(width: item_width, height: 50)
                        .border(Color.black, width: 2)
                }
            }
        }.frame(width: min(CGFloat(sets.sets.count) * item_width, CGFloat(item_width * 4)), alignment: .center)
    }
}

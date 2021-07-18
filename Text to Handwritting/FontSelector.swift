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
    @State var showingDeletionConfirmation = false
    
    private var itemWidth = CGFloat(150)
    
    var body: some View {
        Button("Create new character set") {
            sets.createSet()
        }
        Button("Delete selected character set") {
            showingDeletionConfirmation = true
        }
        Button("Edit character set") {
            showingCharSetCreator = true
        }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(CharSets.sets.keys), id: \.self) { option in
                    Text(sets.sets[option]!.name)
                        .foregroundColor(sets.primarySet == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ sets.primarySet = option }))
                        .frame(width: itemWidth, height: 50)
                        .border(Color.black, width: 2)
                }
            }
        }
        .frame(width: min(CGFloat(sets.sets.count) * itemWidth, CGFloat(itemWidth * 4)), alignment: .center)
        .sheet(isPresented: $showingCharSetCreator) {
            FontEditor()
        }
        .alert(isPresented: $showingDeletionConfirmation) {
            Alert(title: Text("Delete set"),
                  message: Text("Are you sure you want to delete the character set '" + sets.getSet().name + "'?"),
                  primaryButton: .default(Text("Delete")) {
                    sets.deleteSet()
                  },
                  secondaryButton: .cancel())
        }
    }
}

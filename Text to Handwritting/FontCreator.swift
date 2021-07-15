//
//  FontCreator.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/15/21.
//

import Foundation
import SwiftUI

struct FontCreator: View {
    @ObservedObject var sets = CharSets
    
    var body: some View {
        let allchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz’‘':,![(.?])\"”;1234567890-"
        let columns: [GridItem] = Array(repeating: GridItem.init(.flexible(), spacing: 20), count: 6)
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach((0..<allchars.count), id: \.self) { i in
                    let set: CharSet = sets.get_set()
                    let char: String = String(allchars[i])
                    VStack {
                        Text(String(allchars[i]))
                        if set.has_character(char: char) {
                            Image(uiImage: set.getImage(char: char))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 40)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .padding(CGFloat(10))
                    .border(Color.black, width: 2)
                    .font(.title2)
                    .overlay(
                        Rectangle()
                            .foregroundColor(set.has_character(char: char) ? .green : .red)
                            .opacity(0.2)
                    )
                }
            }
        }
        .scaleEffect(CGFloat(0.8))
        
    }
}

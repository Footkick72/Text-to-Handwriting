//
//  InfoView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 8/10/21.
//

import Foundation
import SwiftUI

struct InfoView: View {
    @Binding var shown: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text(
                """
                Text to Handwriting
                
                ©2021 by Daniel Christopher Long
                
                To learn how to use this app,
                read the file "Instructions.txt" in your filesystem.
                
                Source code availiable under standard MIT License at:
                """
            )
            Link("https://github.com/Footkick72/Text-to-Handwriting", destination: URL(string: "https://github.com/Footkick72/Text-to-Handwriting")!)
            Text(
                """
                To submit feedback or report a bug,
                please email me with a description of your concern
                and reproduction steps at text2handwriting@daniellong.org
                """
            )
            Link("Privacy policy", destination: URL(string: "https://daniellong.org/text2handwriting/privacy.html")!)
            Button("Ok") {
                shown = false
            }
        }
        .multilineTextAlignment(.center)
    }
}

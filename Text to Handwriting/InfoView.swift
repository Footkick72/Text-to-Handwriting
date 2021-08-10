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
                
                Source code availiable at:
                https://github.com/Footkick72/Text-to-Handwriting
                MIT License
                
                To learn how to use this app,
                read the file "Instructions.txt" in your filesystem.
                """
            )
            .multilineTextAlignment(.center)
            Button("Ok") {
                shown = false
            }
        }
    }
}

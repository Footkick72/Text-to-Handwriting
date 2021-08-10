//
//  InfoView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 8/10/21.
//

import Foundation
import SwiftUI

struct InfoView: View {
    var body: some View {
        Text(
            """
                        Text to Handwritting
            
                        ©2021 by Daniel Christopher Long
            
                        Source code availiable at:
                        https://github.com/Footkick72/Text-to-Handwritting
                        MIT License
            
                        To learn how to use this app,
                        read the file "Instructions.txt" in your filesystem.
            """
        )
        .multilineTextAlignment(.center)
    }
}

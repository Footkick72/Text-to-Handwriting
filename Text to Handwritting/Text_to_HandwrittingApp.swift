//
//  Text_to_HandwrittingApp.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

@main
struct Text_to_HandwrittingApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: Text_to_HandwrittingDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

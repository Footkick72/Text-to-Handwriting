//
//  Text_to_HandwrittingApp.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI
import Photos

@main
struct Text_to_HandwrittingApp: App {
    init() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: { _ in return })
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: Text_to_HandwrittingDocument()) { file in
            ContentView(document: file.$document)
                .onAppear() {
                    CharSets.load_sets()
                }
                .onDisappear() {
                    CharSets.save_sets()
                }
        }
    }
}

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
        NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: .main) { _ in
            CharSets.load()
            Templates.load()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            CharSets.save()
            Templates.save()
        }
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: Text_to_HandwrittingDocument()) { file in
            ContentView(document: file.$document)
        }
        DocumentGroup(newDocument: CharSetDocument()) { file in
            FontEditor(document: file.$document)
        }
        DocumentGroup(newDocument: TemplateDocument()) { file in
            TemplateEditor(document: file.$document)
        }
    }
}

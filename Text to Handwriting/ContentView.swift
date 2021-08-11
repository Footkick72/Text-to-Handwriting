//
//  ContentView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI
import Photos

struct ContentView: View {
    @Binding var document: Text_to_HandwritingDocument
    @State var showingGenerationOptions = false
    @State var showingNoPermissionAlert = false
    @State var showingInfoScreen = false
    
    var body: some View {
        if document.corrupted {
            Text("File is corrupted, unable to read!")
        } else {
            TextEditor(text: $document.text)
                .navigationBarItems(leading:
                                        Button(action: {
                                            showingInfoScreen = true
                                        }) {
                                            Image(systemName: "info.circle")
                                                .font(.body)
                                        },
                                    trailing:
                                        Button("Handwrite") {
                                            if PHPhotoLibrary.checkPhotoSavePermission() {
                                                showingGenerationOptions = true
                                            } else {
                                                showingNoPermissionAlert = true
                                            }
                                        }
                                        .font(.body)
                                        .sheet(isPresented: $showingGenerationOptions) {
                                            OptionsView(document: $document, shown: $showingGenerationOptions)
                                        }
                                        .alert(isPresented: $showingNoPermissionAlert) {
                                            Alert(title: Text("Cannot convert to handwriting"), message: Text("Text to Handwriting does not have permission to save images to your photo library"), dismissButton: .default(Text("Ok")))
                                        }
                )
                .sheet(isPresented: $showingInfoScreen) {
                    InfoView(shown: $showingInfoScreen)
                }
        }
    }
}

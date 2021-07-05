//
//  ContentView.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @State private var showingGenerationOptions = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center, spacing: 10) {
                Button("generate image") {
                    showingGenerationOptions.toggle()
                }
            }
            TextEditor(text: $document.text)
        }
        
        .sheet(isPresented: $showingGenerationOptions) {
            OptionsView(document: $document, shown: $showingGenerationOptions)
        }
    }
}

struct OptionsView: View {
    @Binding var document: Text_to_HandwrittingDocument
    @Binding var shown: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 200) {
            VStack(alignment: .center, spacing: 20) {
                Text("Font")
                FontSelector()
            }
            VStack(alignment: .center, spacing: 20) {
                Text("Paper")
                TemplateSelector()
            }
            HStack(alignment: .center, spacing: 50) {
                Button("generate") {
                    document.createImage()
                }
                Button("cancel") {
                    shown = false
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct TemplateSelector: View {
    @State private var selectedBackground = Templates.primary_template
    private var item_width = CGFloat(180)
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                ForEach(Array(Templates.templates.keys), id: \.self) { option in
                    VStack(alignment: .center, spacing: 5) {
                        Text(option)
                        Image(uiImage: Templates.templates[option]!.get_bg())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .border(Color.black)
                            .frame(width: item_width, height: 220)
                            .tag(option)
                    }
                    .foregroundColor(selectedBackground == option ? .red : .black)
                    .gesture(TapGesture().onEnded({ Templates.primary_template = option; selectedBackground = option}))
                }
            }
        }.frame(width: min(CGFloat(Templates.templates.count) * (item_width), CGFloat((item_width) * 3)), alignment: .center)

    }
}

struct FontSelector: View {
    @State private var selectedFont = CharSets.primary_set
    private var item_width = CGFloat(150)
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(CharSets.sets.keys), id: \.self) { option in
                    Text(option)
                        .foregroundColor(selectedFont == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ CharSets.primary_set = option; selectedFont = option}))
                        .frame(width: item_width, height: 50)
                        .border(Color.black, width: 2)
                }
            }
        }.frame(width: min(CGFloat(CharSets.sets.count) * item_width, CGFloat(item_width * 4)), alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(Text_to_HandwrittingDocument()))
    }
}

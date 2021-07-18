//
//  TemplateSelector.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

enum templateViews: Identifiable {
    case Creation
    case Editing
    var id: Int {
        hashValue
    }
}

struct TemplateSelector: View {
    @ObservedObject var templates = Templates
    @State var templateViewState: templateViews?
    @State var showingTemplateDeletionConfirmation = false
    private var item_width = CGFloat(180)
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            VStack(alignment: .center, spacing: 10) {
                Button("Add template") {
                    templateViewState = .Creation
                }
                Button("Edit slected template") {
                    templateViewState = .Editing
                }
                Button("Delete selected template") {
                    showingTemplateDeletionConfirmation = true
                }
                .foregroundColor(.red)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(Array(Templates.templates.keys), id: \.self) { option in
                        VStack(alignment: .center, spacing: 5) {
                            Text(option)
                            Image(uiImage: Templates.templates[option]!.get_bg())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(Color.black)
                                .frame(width: item_width)
                                .tag(option)
                        }
                        .foregroundColor(templates.primaryTemplate == option ? .red : .black)
                        .gesture(TapGesture().onEnded({ templates.primaryTemplate = option }))
                    }
                }
            }.frame(width: min(CGFloat(templates.templates.count) * (item_width), CGFloat((item_width) * 3)), alignment: .center)
        }
        .sheet(item: $templateViewState) { item in
            switch item {
            case .Creation:
                TemplateCreator(shown: $templateViewState)
            case .Editing:
                TemplateEditor(shown: $templateViewState)
            }
        }
        .alert(isPresented: $showingTemplateDeletionConfirmation) {
            Alert(title: Text("Delete Template"),
                  message: Text("Are you sure you want to delete template \"" + templates.get_template().name + "\"?"),
                  primaryButton: .destructive(Text("Yes")) {
                    templates.deleteTemplate()
                  },
                  secondaryButton: .cancel())
        }
    }
}

//
//  AddCharsView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 12/30/22.
//

import Foundation
import SwiftUI


struct AddCharsView: View {
    @Binding var document: CharSetDocument
    @Binding var showAddView: Bool
    
    var body: some View {
        VStack {
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "English", chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "Русский", chars: "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "беларускі", chars: "АаБбВвГгҐґДдЕеЁёЖжЗзІіЙйКкЛлМмНнОоПпРрСсТтУуЎўФфХхЦцЧчШшЫыЬьЭэЮюЯя")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "Українська", chars: "АаБбВвГгҐґДдЕеЄєЖжЗзИиІіЇїЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЬьЮюЯя")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "български", chars: "АаБбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЬьЮюЯя")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "Numbers", chars: "1234567890")
            AddCharsPreset(document: $document, showAddView: $showAddView, name: "Math/Symbols", chars: "':,![(.?])\";-%@&+={}#$^*_/\\~<>")
            AddCharsUsingPasteView(document: $document, showAddView: $showAddView)
        }
    }
}

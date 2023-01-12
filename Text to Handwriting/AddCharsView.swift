//
//  AddCharsView.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 12/30/22.
//

import Foundation
import SwiftUI

enum Preset: Identifiable, CaseIterable {
    case English, Русский, Українська, български, Español, Deutsche, Numbers, MathSymbols
    var id: Self {self}
    var name: String {
        switch self {
        case .English: return "English"
        case .Русский: return "Русский"
        case .Українська: return "Українська"
        case .български: return "български"
        case .Español: return "Español"
        case .Deutsche: return "Deutsche"
        case .Numbers: return "Numbers"
        case .MathSymbols: return "Math/Symbols"
        }
    }
    var chars: String {
        switch self {
        case .English: return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        case .Русский: return "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя"
        case .Українська: return "АаБбВвГгҐґДдЕеЁёЖжЗзІіЙйКкЛлМмНнОоПпРрСсТтУуЎўФфХхЦцЧчШшЫыЬьЭэЮюЯя"
        case .български: return "АаБбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЬьЮюЯя"
        case .Español: return "AÁBCDEÉFGHIÍJKLMNÑOÓPQRSTUÚVWXYZaábcdeéfghiíjklmnñoópqrstuúvwxyz"
        case .Deutsche: return "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜßabcdefghijklmnopqrstuvwxyzäöü"
        case .Numbers: return "1234567890"
        case .MathSymbols: return "':,![(.?])\";-%@&+={}#$^*_/\\~<>"
        }
    }
}

struct AddCharsView: View {
    @Binding var document: CharSetDocument
    @Binding var showAddView: Bool
    @State var selectedPreset: Preset = .English
    
    var body: some View {
        VStack {
            Picker("Character Set", selection: $selectedPreset) {
                ForEach(Preset.allCases) { selection in
                    Text(selection.name)
                }
            }
            .frame(width: 200)
            .pickerStyle(.wheel)
            
            Button("Add") {
                document.object.addChars(chars: selectedPreset.chars)
                showAddView = false
            }
            .padding(10)
            .foregroundColor(.blue)
            
            AddCharsUsingPasteView(document: $document, showAddView: $showAddView)
            
            Button("Cancel") {
                showAddView = false
            }
            .padding(10)
            .foregroundColor(.blue)
        }
    }
}

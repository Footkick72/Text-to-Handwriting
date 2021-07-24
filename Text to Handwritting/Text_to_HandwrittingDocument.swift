//
//  Text_to_HandwrittingDocument.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Photos

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "org.davidlong.plain-text")
    }
}

struct Text_to_HandwrittingDocument: FileDocument {
    var text: String

    init(text: String = "Hello, world!") {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.exampleText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    func get_expected_length(word: String, charlens: Dictionary<String,Float>, space_length: Float) -> Int{
        var length: Float = 0.0
        for char in word {
            if charlens.keys.firstIndex(of: String(char)) != nil {
                length += charlens[String(char)]!
            } else {
                length += space_length
            }
        }
        return Int(length)
    }
    
    func checkPhotoSavePermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
            case .notDetermined:
                // The user hasn't determined this app's access.
                return false
            case .restricted:
                // The system restricted this app's access.
                return false
            case .denied:
                // The user explicitly denied this app's access.
                return false
            case .authorized:
                // The user authorized this app to access Photos data.
                return true
            case .limited:
                // The user authorized this app for limited Photos access.
                return false
            @unknown default:
                fatalError()
        }
    }
    
    func createImage(charset: CharSet, template: Template) -> Void {
//        let words = self.text.split(separator: " ")
        let words = self.text.components(separatedBy: CharacterSet(charactersIn: " \n"))
        
        let font_size = template.font_size
        let left_margin = template.getMargins()[0]
        let right_margin = template.getMargins()[1]
        let top_margin = template.getMargins()[2]
        let bottom_margin = template.getMargins()[3]
        
        let line_spacing = Int(font_size + 4)
        let letter_spacing: Int = Int(Double(font_size) * 0.2)
        let space_length = Int(Double(font_size) * 0.8)
        let line_end_buffer = Int(font_size * 2)
        
        var image = template.getBackground()
        let size = [Int(image.size.width), Int(image.size.height)]
        
        var x_pos = left_margin
        var y_pos = top_margin
        var page_i:Int = 1
        var char_i:Int = 0
        var pencil_hardness:Float = 0.8
        let max_hardness:Float = 0.9
        let min_hardness:Float = 0.7
        var line_offset:Float = 0

        var charlens: Dictionary<String,Float> = charset.charlens
        for k in charlens.keys {
            charlens[k] = charlens[k]! * Float(font_size)
            charlens[k] = charlens[k]! +  Float(letter_spacing) * Float(font_size) / 256.0
        }
        
        for word in words {
            while self.text[char_i] == " " || self.text[char_i] == "\n" {
                if self.text[char_i] == " " {
                    x_pos += space_length
                } else {
                    x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                    y_pos += line_spacing
                    if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                        y_pos = top_margin
                        if checkPhotoSavePermission() {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                        image = template.getBackground()
                        page_i += 1
                    }
                }
                char_i += 1
            }
            
            let expected_length = get_expected_length(word: String(word), charlens: charlens, space_length: Float(space_length)) + space_length + line_end_buffer
            if x_pos + expected_length >= size[0] - right_margin - left_margin {
                x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                y_pos += line_spacing
                if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                    y_pos = top_margin
                    if checkPhotoSavePermission() {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    image = template.getBackground()
                    page_i += 1
                }
            }
            
            for char in word {
                if var letter = charset.getImage(char: String(char)) {
                    letter = letter.cropAlpha(cropVertical: false, cropHorizontal: true)
                    let scaler = Float(letter.size.height)/Float(font_size)
                    letter = UIImage(cgImage: letter.cgImage!, scale: CGFloat(scaler), orientation: letter.imageOrientation)
                    var letterlength = Float(letter.size.width)
                    let s = CGSize(width: size[0], height: size[1])
                    UIGraphicsBeginImageContext(s)
                    let areaSize = CGRect(x: 0, y: 0, width: s.width, height: s.height)
                    image.draw(in: areaSize)
                    let letterRect = CGRect(x: CGFloat(Int(x_pos + 80)), y: CGFloat(y_pos + Int(line_offset) + 64), width: letter.size.width, height: letter.size.height)
                    letter.draw(in: letterRect, blendMode: .normal, alpha: CGFloat(pencil_hardness))
                    image = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    letterlength += (Float.random(in: 0..<1) - 0.5) * 2.0
                    
                    x_pos += Int(letterlength + Float(letter_spacing) + Float.random(in: 0..<1) * 0.2)
                    pencil_hardness += (Float.random(in: 0..<1) - 0.5) * 0.2
                    pencil_hardness = max(min(pencil_hardness, max_hardness), min_hardness)
                    line_offset += (Float.random(in: 0..<1) - 0.5) * 0.25
                    line_offset = max(min(line_offset, 4), -4)
//                    line_offset = 0
                } else {
                    x_pos += space_length
                }
            }
            
            char_i += word.count
        }
        if checkPhotoSavePermission() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return
    }
}

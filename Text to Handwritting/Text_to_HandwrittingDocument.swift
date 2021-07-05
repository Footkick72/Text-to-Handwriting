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
        UTType(importedAs: "com.example.plain-text")
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
    
    func get_expected_length(word: String, charlens: Dictionary<String,Float>) -> Int{
        var length: Float = 0.0
        for char in word {
            length += charlens[String(char)]!
        }
        return Int(length)
    }
    
    func checkPhotoSavePermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
            case .notDetermined:
                // The user hasn't determined this app's access.
//                PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: <#T##(PHAuthorizationStatus) -> Void#>)
//                return checkPhotoSavePermission()
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
    
    func createImage() -> Void {
//        let words = self.text.split(separator: " ")
        let words = self.text.components(separatedBy: CharacterSet(charactersIn: " \n"))

        let template = Templates.get_template()
        
        let size = [Int(8.5 * 100), Int(11 * 100)]
        let font_size = template.font_size

        let left_margin = template.margins[0]
        let right_margin = template.margins[1]
        let top_margin = template.margins[2]
        let bottom_margin = template.margins[3]

        let line_spacing = template.line_spacing
        let letter_spacing = template.letter_spacing
        let space_length = template.space_length
        let line_end_buffer = template.line_end_buffer
        
        var image = template.get_bg()
        var x_pos = left_margin
        var y_pos = top_margin
        var page_i:Int = 1
        var char_i:Int = 0
        var pencil_hardness:Float = 0.8
        let max_hardness:Float = 0.9
        let min_hardness:Float = 0.7
        var line_offset:Float = 0

        var charlens: Dictionary<String,Float> = [:]
        for char in CharSets.get_set().availiable_chars {
            var charlen: Float = 0
            let images: Array<UIImage>
            do {
                images = try CharSets.get_set().getImages(char: String(char))!
            } catch {
                print("Charset failed to return image on character " + String(char) + " during charlens calculation, aborting...")
                return
            }
            for file in images {
                let box = file.cropAlpha(cropVertical: true, cropHorizontal: true).size
                let scaler: Float = Float(font_size)/Float(file.size.width)
                charlen += Float(Int(box.width) + letter_spacing) * scaler
            }
            charlens[String(char)] = charlen/Float(images.count)
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
                        image = UIImage(contentsOfFile: Bundle.main.resourcePath! + "/paper.png")!
                        page_i += 1
                    }
                }
                char_i += 1
            }
            
            let expected_length = get_expected_length(word: String(word), charlens: charlens) + space_length + line_end_buffer
            if x_pos + expected_length >= size[0] - right_margin - left_margin {
                x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                y_pos += line_spacing
                if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                    y_pos = top_margin
                    if checkPhotoSavePermission() {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    image = UIImage(contentsOfFile: Bundle.main.resourcePath! + "/paper.png")!
                    page_i += 1
                }
            }
            
            for char in word {
                var letter: UIImage
                do {
                    try letter = CharSets.get_set().getImage(char: String(char))!
                } catch {
                    print("Charset failed to return image on character " + String(char) + " during image generation, aborting...")
                    return
                }
                letter = letter.cropAlpha(cropVertical: false, cropHorizontal: true)
                let scaler = Float(letter.size.height)/Float(font_size)
//                let scaler = 10
//                var letter = letter.resize((max(1,int(letter.size[0] * scaler)), font_size), resample = Image.LANCZOS)
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
                line_offset = 0
            }
            
            char_i += word.count
        }
        if checkPhotoSavePermission() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return
    }
}

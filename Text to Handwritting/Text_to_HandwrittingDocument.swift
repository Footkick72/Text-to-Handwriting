//
//  Text_to_HandwritingDocument.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/29/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Photos
import PencilKit

extension UTType {
    static var exampleText: UTType {
        UTType(importedAs: "org.davidlong.plain-text")
    }
}

struct Text_to_HandwritingDocument: FileDocument {
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
    
    func createImage(charset: CharSet, template: Template, updateProgress: (Double, Bool, Bool) -> Void) -> Void {
        var words = self.text.components(separatedBy: CharacterSet(charactersIn: " \n"))
        for word in words {
            if word == "" || word == "\n" {
                words.remove(at: words.firstIndex(of: word)!)
            }
        }
        
        let font_size = template.fontSize
        let left_margin = template.getMargins()[0]
        let right_margin = template.getMargins()[1]
        let top_margin = template.getMargins()[2]
        let bottom_margin = template.getMargins()[3]
        
        let line_spacing = Int(font_size + 4)
        let letter_spacing: Int = charset.letterSpacing
        let space_length = Int(Double(font_size) * 0.5)
        let line_end_buffer = Int(font_size)
        
        var image = PKDrawing()
        let size = [Int(template.getBackground().size.width), Int(template.getBackground().size.height)]
        
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
            charlens[k] = charlens[k]! * Float(font_size) / 256
            charlens[k] = charlens[k]! +  Float(letter_spacing) * Float(font_size) / 256.0
        }
        
        updateProgress(0.0, true, false)
        
        var word_i = 0
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
                            UIGraphicsBeginImageContext(CGSize(width: size[0], height: size[1]))
                            template.getBackground().draw(at: CGPoint(x: 0, y: 0))
                            image.image(from: CGRect(x: 0, y: 0, width: size[0], height: size[1]), scale: 5.0).draw(at: CGPoint(x: 0, y: 0))
                            let result = UIGraphicsGetImageFromCurrentImageContext()!
                            UIGraphicsEndImageContext()
                            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                        }
                        image = PKDrawing()
                        page_i += 1
                    }
                }
                char_i += 1
            }
            
            let expected_length = get_expected_length(word: String(word), charlens: charlens, space_length: Float(space_length)) + space_length + line_end_buffer
            if x_pos + expected_length >= size[0] - right_margin {
                x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                y_pos += line_spacing
                if y_pos >= size[1] - line_spacing - bottom_margin {
                    y_pos = top_margin
                    if checkPhotoSavePermission() {
                        UIGraphicsBeginImageContext(CGSize(width: size[0], height: size[1]))
                        template.getBackground().draw(at: CGPoint(x: 0, y: 0))
                        image.image(from: CGRect(x: 0, y: 0, width: size[0], height: size[1]), scale: 5.0).draw(at: CGPoint(x: 0, y: 0))
                        let result = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                        UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                    }
                    image = PKDrawing()
                    page_i += 1
                }
            }
            
            for char in word {
                if var letter = charset.getImage(char: String(char)) {
                    letter.transform(using: CGAffineTransform(translationX: -letter.bounds.minX, y: 0))
                    letter.transform(using: CGAffineTransform(scaleX: CGFloat(font_size/256.0), y: CGFloat(font_size/256)))
                    letter.transform(using: CGAffineTransform(translationX: CGFloat(x_pos), y: CGFloat(y_pos + Int(line_offset))))
                    image.append(letter)
                    
                    var letterlength = Float(letter.bounds.width)
                    letterlength += (Float.random(in: 0..<1) - 0.5) * 2.0
                    x_pos += Int(letterlength + Float(letter_spacing) + Float.random(in: 0..<1) * 0.2)
                    pencil_hardness += (Float.random(in: 0..<1) - 0.5) * 0.2
                    pencil_hardness = max(min(pencil_hardness, max_hardness), min_hardness)
                    line_offset += (Float.random(in: 0..<1) - 0.5) * 0.25
                    line_offset = max(min(line_offset, 4), -4)
                } else {
                    x_pos += space_length
                }
            }
            
            char_i += word.count
            word_i += 1
            updateProgress(Double(word_i)/Double(words.count), true, false)
        }
        if checkPhotoSavePermission() {
            UIGraphicsBeginImageContext(CGSize(width: size[0], height: size[1]))
            template.getBackground().draw(at: CGPoint(x: 0, y: 0))
            let color = UIColor(red: CGFloat(template.textColor[0]), green: CGFloat(template.textColor[1]), blue: CGFloat(template.textColor[2]), alpha: CGFloat(template.textColor[3]))
            var newDrawingStrokes = [PKStroke]()
            for stroke in image.strokes {
                //yes, I am aware this code appears to make an exact copy of stroke with a different ink. Why does it produce different behavior that doing just that? I don't know. PKDrawing is weird.
                var newPoints = [PKStrokePoint]()
                stroke.path.forEach { (point) in
                    newPoints.append(point)
                }
                let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
                var ink: PKInk
                switch template.writingStyle {
                case "Pen":
                    ink = PKInk(.pen, color: color)
                case "Pencil":
                    ink = PKInk(.pencil, color: color)
                case "Marker":
                    ink = PKInk(.marker, color: color)
                default:
                    fatalError("selected template's writingStyle is \(template.writingStyle), invalid!")
                }
                var newStroke = PKStroke(ink: ink, path: newPath)
                newStroke.transform = stroke.transform
                newDrawingStrokes.append(newStroke)
            }
            UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
                PKDrawing(strokes: newDrawingStrokes).image(from: CGRect(x: 0, y: 0, width: size[0], height: size[1]), scale: 5.0).draw(at: CGPoint(x: 0, y: 0))
            }
            let result = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
        }
        updateProgress(0.0, false, true)
        return
    }
}

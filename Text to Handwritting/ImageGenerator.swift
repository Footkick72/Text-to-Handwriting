//
//  ImageGenerator.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 8/4/21.
//

import Foundation
import Photos
import PencilKit

class ImageGenerator: NSObject {
    var text: String
    var charset: CharSet
    var template: Template
    var updateProgress: (Double, Bool, Bool) -> Void
    
    var font_size: Float
    var left_margin: Int
    var right_margin: Int
    var top_margin: Int
    var bottom_margin: Int
    
    var line_spacing: Int
    var letter_spacing: Int
    var space_length: Int
    var line_end_buffer: Int
    
    var image = PKDrawing()
    var size: Array<Int>
    
    var x_pos: Int
    var y_pos: Int
    var line_offset:Float = 0

    var charlens: Dictionary<String,Float>
    
    var semaphore = DispatchSemaphore(value: 0)
    
    init(text: String, charset: CharSet, template: Template, updateProgress: @escaping (Double, Bool, Bool) -> Void) {
        self.text = text
        self.charset = charset
        self.template = template
        self.updateProgress = updateProgress
        self.font_size = template.fontSize
        self.left_margin = template.getMargins()[0]
        self.right_margin = template.getMargins()[1]
        self.top_margin = template.getMargins()[2]
        self.bottom_margin = template.getMargins()[3]
        
        self.line_spacing = Int(font_size + 4)
        self.letter_spacing = charset.letterSpacing
        self.space_length = Int(Double(font_size) * 0.5)
        self.line_end_buffer = Int(font_size)
        
        self.image = PKDrawing()
        self.size = [Int(template.getBackground().size.width), Int(template.getBackground().size.height)]
        
        self.x_pos = left_margin
        self.y_pos = top_margin

        self.charlens = charset.charlens
        for (k, v) in charlens {
            charlens[k] = (v  + Float(letter_spacing)) * Float(font_size) / 256
        }
        
        updateProgress(0.0, true, false)
    }
    
    func get_expected_length(word: String) -> Int{
        var length: Float = 0.0
        for char in word {
            if let len = charlens[String(char)] {
                length += len
            } else {
                length += Float(space_length)
            }
        }
        return Int(length)
    }
    
    func generateWord(_ letter: inout PKDrawing) {
        letter.transform(using: CGAffineTransform(translationX: -letter.bounds.minX, y: 0))
        letter.transform(using: CGAffineTransform(scaleX: CGFloat(font_size/256.0), y: CGFloat(font_size/256)))
        letter.transform(using: CGAffineTransform(translationX: CGFloat(x_pos), y: CGFloat(y_pos + Int(line_offset))))
        image.append(letter)
        
        var letterlength = Float(letter.bounds.width)
        letterlength += (Float.random(in: 0..<1) - 0.5) * 2.0
        x_pos += Int(letterlength + Float(letter_spacing) + Float.random(in: 0..<1) * 0.2)
        line_offset += (Float.random(in: 0..<1) - 0.5) * 0.25
        line_offset = max(min(line_offset, 4), -4)
    }
    
    func getMarkdownWord(_ char_i: String.Index) -> String {
        var end_i = self.text.index(after: char_i)
        while end_i != self.text.index(before: self.text.endIndex) && self.text[end_i] != self.text[char_i] && !self.text[end_i].isWhitespace {
            end_i = self.text.index(after: end_i)
        }
        return String(self.text[char_i...end_i])
    }
    
    func createImage() {
        
        var generated = 0
        var char_i = self.text.startIndex
        while char_i != self.text.endIndex {
            if self.text[char_i] == " " {
                x_pos += space_length
                
                generated += 1
                char_i = self.text.index(after: char_i)
                updateProgress(Double(generated)/Double(self.text.count), true, false)
            } else if self.text[char_i] == "\t" {
                x_pos += space_length * 4
                
                generated += 1
                char_i = self.text.index(after: char_i)
                updateProgress(Double(generated)/Double(self.text.count), true, false)
            } else if self.text[char_i] == "\n" {
                x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                y_pos += line_spacing
                if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                    y_pos = top_margin
                    self.savePage(template: template, image: &image)
                }
                
                generated += 1
                char_i = self.text.index(after: char_i)
                updateProgress(Double(generated)/Double(self.text.count), true, false)
            } else if self.text[char_i].isLetter {
                
                var end_i = self.text.index(after: char_i)
                while end_i != self.text.endIndex && self.text[end_i].isLetter {
                    end_i = self.text.index(after: end_i)
                }
                let word = String(self.text[char_i..<end_i])
                
                let expected_length = get_expected_length(word: String(word)) + space_length + line_end_buffer
                if x_pos + expected_length >= size[0] - right_margin {
                    x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                    y_pos += line_spacing
                    if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                        y_pos = top_margin
                        self.savePage(template: template, image: &image)
                    }
                }
                
                for char in word {
                    if var letter = charset.getImage(char: String(char)) {
                        generateWord(&letter)
                    } else {
                        x_pos += space_length
                    }
                    
                    generated += 1
                    char_i = self.text.index(after: char_i)
                    updateProgress(Double(generated)/Double(self.text.count), true, false)
                }
                
            } else if "*_~".contains(self.text[char_i]) && getMarkdownWord(char_i).last! == self.text[char_i] {
                
                var word = getMarkdownWord(char_i)
                
                var isUnderline = false
                var isStrikethrough = false
                var isBold = false
                if word.first == "*" && word.last == "*" {
                    isBold = true
                } else if word.first == "~" && word.last == "~" {
                    isStrikethrough = true
                } else if word.first == "_" && word.last == "_" {
                    isUnderline = true
                }
                word.remove(at: word.startIndex)
                word.remove(at: word.index(before: word.endIndex))
                char_i = self.text.index(char_i, offsetBy: 2)
                
                let expected_length = get_expected_length(word: String(word)) + space_length + line_end_buffer
                if x_pos + expected_length >= size[0] - right_margin {
                    x_pos = Int(Float(left_margin) * (1.0 + (Float.random(in: 0..<1) - 0.5) * 0.2))
                    y_pos += line_spacing
                    if y_pos >= size[1] - line_spacing - bottom_margin - top_margin {
                        y_pos = top_margin
                        self.savePage(template: template, image: &image)
                    }
                }
                
                var wordPath = Array<PKStrokePoint>()
                var pathY: CGFloat = 0
                
                for char in word {
                    if var letter = charset.getImage(char: String(char)) {
                        
                        if isBold {
                            var boldStrokes = [PKStroke]()
                            for stroke in letter.strokes {
                                var newPoints = [PKStrokePoint]()
                                stroke.path.forEach { (point) in
                                    let newPoint = PKStrokePoint(location: point.location,
                                                                 timeOffset: point.timeOffset,
                                                                 size: point.size.applying(CGAffineTransform(scaleX: 2, y: 2)),
                                                                 opacity: point.opacity, force: point.force,
                                                                 azimuth: point.azimuth, altitude: point.altitude)
                                    newPoints.append(newPoint)
                                }
                                let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
                                var newStroke = PKStroke(ink: PKInk(.pen, color: UIColor.white), path: newPath)
                                newStroke.transform = stroke.transform
                                boldStrokes.append(newStroke)
                            }
                            letter = PKDrawing(strokes: boldStrokes)
                        }
                        
                        generateWord(&letter)
                        
                        let idealY = isStrikethrough ? letter.bounds.midY : letter.bounds.maxY + 4
                        if pathY == 0 {
                            pathY = idealY
                        } else {
                            pathY += CGFloat.random(in: -2...2)
                            let t: CGFloat = 0.1
                            pathY = pathY * (1.0 - t) + idealY * t
                        }
                        
                        let point = PKStrokePoint(location: CGPoint(x: letter.bounds.midX,
                                                                    y: pathY),
                                                  timeOffset: TimeInterval(),
                                                  size: CGSize(width: 3, height: 3),
                                                  opacity: 1.0, force: 1.0,
                                                  azimuth: 0.0, altitude: 0.0)
                        wordPath.append(point)
                    } else {
                        x_pos += space_length
                    }
                    
                    generated += 1
                    char_i = self.text.index(after: char_i)
                    updateProgress(Double(generated)/Double(self.text.count), true, false)
                }
                
                let path = PKStrokePath(controlPoints: wordPath, creationDate: Date())
                if isUnderline || isStrikethrough {
                    let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
                    let drawing = PKDrawing(strokes: [stroke])
                    image.append(drawing)
                }
            } else {
                if var letter = charset.getImage(char: String(self.text[char_i])) {
                    
                    letter.transform(using: CGAffineTransform(translationX: -letter.bounds.minX, y: 0))
                    letter.transform(using: CGAffineTransform(scaleX: CGFloat(font_size/256.0), y: CGFloat(font_size/256)))
                    letter.transform(using: CGAffineTransform(translationX: CGFloat(x_pos), y: CGFloat(y_pos + Int(line_offset))))
                    image.append(letter)
                    
                    var letterlength = Float(letter.bounds.width)
                    letterlength += (Float.random(in: 0..<1) - 0.5) * 2.0
                    x_pos += Int(letterlength + Float(letter_spacing) + Float.random(in: 0..<1) * 0.2)
                    line_offset += (Float.random(in: 0..<1) - 0.5) * 0.25
                    line_offset = max(min(line_offset, 4), -4)
                } else {
                    x_pos += space_length
                }
                
                generated += 1
                char_i = self.text.index(after: char_i)
                updateProgress(Double(generated)/Double(self.text.count), true, false)
            }
        }
        self.savePage(template: template, image: &image)
        updateProgress(0.0, false, true)
    }
    
    func savePage(template: Template, image: inout PKDrawing) {
        UIGraphicsBeginImageContext(template.getBackground().size)
        template.getBackground().draw(at: CGPoint.zero)
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
            let drawing = PKDrawing(strokes: newDrawingStrokes)
            let img = drawing.image(from: CGRect(x: 0,
                                                 y: 0,
                                                 width: template.getBackground().size.width,
                                                 height: template.getBackground().size.height),
                                    scale: 3.0)
            img.draw(at: CGPoint.zero)
            
        }
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("UIGraphicsImageContent is not initialized") }
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(UIImage(data: result.pngData()!)!, self, #selector(nextPage(_:didFinishSavingWithError:contextInfo:)), nil)
        
        image = PKDrawing()
        semaphore.wait()
    }
    
    @objc func nextPage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        semaphore.signal()
    }
}

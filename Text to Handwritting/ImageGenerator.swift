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
    
    var line_spacing: Float
    var letter_spacing: Int
    var space_length: Int
    var line_end_buffer: Int
    
    var image = PKDrawing()
    var size: Array<Int>
    
    var x_pos: Float
    var y_pos: Float
    var line_offset:Float = 0
    
    var semaphore = DispatchSemaphore(value: 0)
    
    var generated = 0
    var char_i: String.Index
    
    var word = PKDrawing()
    
    var underlinePath = Array<PKStrokePoint>()
    var underlinePathY: CGFloat = 0
    var strikethroughPath = Array<PKStrokePoint>()
    var strikethroughPathY: CGFloat = 0
    
    var proceedingMarkdownCharCount = 0
    var isBold = false
    var isUnderline = false
    var isStrikethrough = false
    
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
        
        self.line_spacing = template.lineSpacing
        self.letter_spacing = charset.letterSpacing
        self.space_length = Int(Double(line_spacing) * 0.5)
        self.line_end_buffer = Int(line_spacing)
        
        self.image = PKDrawing()
        self.size = [Int(template.getBackground().size.width), Int(template.getBackground().size.height)]
        
        self.x_pos = Float(left_margin)
        self.y_pos = Float(top_margin)
        
        self.char_i = self.text.startIndex
        
        updateProgress(0.0, true, false)
    }
    
    func createNewLine() {
        
        // draw underlines and strikethroughs
        if isUnderline {
            let path = PKStrokePath(controlPoints: underlinePath, creationDate: Date())
            let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
            let drawing = PKDrawing(strokes: [stroke])
            image.append(drawing)
            underlinePath = Array<PKStrokePoint>()
            underlinePathY = 0
        }
        
        if isStrikethrough {
            let path = PKStrokePath(controlPoints: strikethroughPath, creationDate: Date())
            let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
            let drawing = PKDrawing(strokes: [stroke])
            image.append(drawing)
            strikethroughPath = Array<PKStrokePoint>()
            strikethroughPathY = 0
        }
        
        // increment positions
        x_pos = Float(left_margin) + Float.random(in: max(-line_spacing * 0.125, -20) ..< min(line_spacing * 0.125, 20))
        y_pos += line_spacing
        if y_pos >= Float(size[1]) - line_spacing - Float(bottom_margin) {
            y_pos = Float(top_margin)
            self.savePage(template: template, image: &image)
        }
    }
    
    func pasteWord() {
        image.append(word)
        word = PKDrawing()
    }
    
    func createImage() {
        while char_i != self.text.endIndex {
            
            
            // decrememnt markdown counter
            if proceedingMarkdownCharCount != 0 {
                proceedingMarkdownCharCount -= 1
            }
            
            
            // word insertion
            if self.text[char_i].isWhitespace {
                pasteWord()
            }
            
            
            // whitespace handling
            if self.text[char_i] == " " {
                x_pos += Float(space_length)
                
            } else if self.text[char_i] == "\t" {
                x_pos += Float(space_length * 4)
                
            } else if self.text[char_i] == "\n" {
                createNewLine()
            }
            
            
            // markdown handling
            else if self.text.index(after: char_i) != self.text.endIndex && self.text[char_i] == "*" && self.text[self.text.index(after: char_i)] == "*" {
                isBold.toggle()
                proceedingMarkdownCharCount = 2
            }
            else if self.text.index(after: char_i) != self.text.endIndex && self.text[char_i] == "_" && self.text[self.text.index(after: char_i)] == "_" {
                isUnderline.toggle()
                proceedingMarkdownCharCount = 2
                
                if !isUnderline {
                    let path = PKStrokePath(controlPoints: underlinePath, creationDate: Date())
                    let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
                    let drawing = PKDrawing(strokes: [stroke])
                    image.append(drawing)
                    underlinePath = Array<PKStrokePoint>()
                    underlinePathY = 0
                }
            }
            else if self.text.index(after: char_i) != self.text.endIndex && self.text[char_i] == "~" && self.text[self.text.index(after: char_i)] == "~" {
                isStrikethrough.toggle()
                proceedingMarkdownCharCount = 2
                
                if !isStrikethrough {
                    let path = PKStrokePath(controlPoints: strikethroughPath, creationDate: Date())
                    let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
                    let drawing = PKDrawing(strokes: [stroke])
                    image.append(drawing)
                    strikethroughPath = Array<PKStrokePoint>()
                    strikethroughPathY = 0
                }
            }
            
            
            // word generation
            else if proceedingMarkdownCharCount == 0 {
                if word.strokes.count == 0 { //we're at the start of the word
                    let oldX = x_pos
                    
                    var end_i = char_i
                    while end_i != self.text.index(before: self.text.endIndex) && !self.text[end_i].isWhitespace {
                        end_i = self.text.index(after: end_i)
                    }
                    let chars = String(self.text[char_i...end_i])
                    
                    var markdown = Array<Int>()
                    for i in 0 ..< chars.count - 1 {
                        if "*_~".contains(chars[i]) && chars[i] == chars[i+1] {
                            markdown.append(i)
                            markdown.append(i+1)
                        }
                    }
                    
                    // approximate the length the word will be
                    for i in 0 ..< chars.count {
                        if var letter = charset.getImage(char: String(chars[i])), !markdown.contains(i) {
                            
                            // regenerate the strokes with added weight
                            var newStrokes = [PKStroke]()
                            for stroke in letter.strokes {
                                var newPoints = [PKStrokePoint]()
                                stroke.path.forEach { (point) in
                                    let newSize = point.size.applying(CGAffineTransform(scaleX: CGFloat(charset.forceMultiplier), y: CGFloat(charset.forceMultiplier)))
                                    let newPoint = PKStrokePoint(location: point.location,
                                                                 timeOffset: point.timeOffset,
                                                                 size: newSize,
                                                                 opacity: point.opacity,
                                                                 force: point.force,
                                                                 azimuth: point.azimuth,
                                                                 altitude: point.altitude)
                                    newPoints.append(newPoint)
                                }
                                let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
                                var newStroke = PKStroke(ink: PKInk(.pen, color: UIColor.white), path: newPath)
                                newStroke.transform = stroke.transform
                                newStrokes.append(newStroke)
                            }
                            
                            letter = PKDrawing(strokes: newStrokes)
                            
                            // properly fill the lines - in the drawingView, the suggested area is half the full box, which is what is otherwise getting mapped on.
                            let fillingScale = CGFloat(1.8 * font_size)
                            letter.transform(using: CGAffineTransform(scaleX: fillingScale, y: fillingScale))
                            letter.transform(using: CGAffineTransform(translationX: -letter.bounds.minX, y: -32 * fillingScale))
                            
                            letter.transform(using: CGAffineTransform(scaleX: CGFloat(line_spacing/256.0), y: CGFloat(line_spacing/256)))
                            letter.transform(using: CGAffineTransform(translationX: CGFloat(x_pos), y: CGFloat(y_pos + line_offset)))
                            word.append(letter)
                            
                            var letterlength = Float(letter.bounds.width)
                            letterlength += Float.random(in: -1 ..< 1)
                            x_pos += letterlength + Float(letter_spacing) + Float.random(in: 0 ..< 0.2)
                        } else {
                            x_pos += Float(space_length)
                        }
                    }
                    
                    if word.bounds.maxX.isFinite && Int(word.bounds.maxX) >= size[0] - right_margin {
                        self.createNewLine()
                    } else {
                        x_pos = oldX
                    }
                    word = PKDrawing()
                }
                
                if var letter = charset.getImage(char: String(self.text[char_i])) {
                    
                    // regenerate the strokes with added weight
                    var newStrokes = [PKStroke]()
                    for stroke in letter.strokes {
                        var newPoints = [PKStrokePoint]()
                        stroke.path.forEach { (point) in
                            var newSize = point.size.applying(CGAffineTransform(scaleX: CGFloat(charset.forceMultiplier), y: CGFloat(charset.forceMultiplier)))
                            if isBold {
                                newSize = point.size.applying(CGAffineTransform(scaleX: 1.5, y: 1.5))
                            }
                            let newPoint = PKStrokePoint(location: point.location,
                                                         timeOffset: point.timeOffset,
                                                         size: newSize,
                                                         opacity: point.opacity,
                                                         force: point.force,
                                                         azimuth: point.azimuth,
                                                         altitude: point.altitude)
                            newPoints.append(newPoint)
                        }
                        let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
                        var newStroke = PKStroke(ink: PKInk(.pen, color: UIColor.white), path: newPath)
                        newStroke.transform = stroke.transform
                        newStrokes.append(newStroke)
                    }
                    
                    letter = PKDrawing(strokes: newStrokes)
                    
                    // properly fill the lines - in the drawingView, the suggested area is half the full box, which is what is otherwise getting mapped on.
                    let fillingScale = CGFloat(1.8 * font_size)
                    letter.transform(using: CGAffineTransform(scaleX: fillingScale, y: fillingScale))
                    letter.transform(using: CGAffineTransform(translationX: -letter.bounds.minX, y: -32 * fillingScale))
                    
                    letter.transform(using: CGAffineTransform(scaleX: CGFloat(line_spacing/256.0), y: CGFloat(line_spacing/256)))
                    letter.transform(using: CGAffineTransform(translationX: CGFloat(x_pos), y: CGFloat(y_pos + line_offset)))
                    word.append(letter)
                    
                    var letterlength = Float(letter.bounds.width)
                    letterlength += Float.random(in: -1 ..< 1)
                    x_pos += letterlength + Float(letter_spacing) + Float.random(in: 0 ..< 0.2)
                    line_offset += Float.random(in: -0.5 ..< 0.5)
                    line_offset = max(min(line_offset, line_spacing * 0.15), -line_spacing * 0.15)
                    
                    
                    // underline path logging
                    if isUnderline {
                        let idealY = letter.bounds.maxY + 4
                        if underlinePathY == 0 {
                            underlinePathY = idealY
                        } else {
                            underlinePathY += CGFloat.random(in: -2...2)
                            let t: CGFloat = 0.1
                            underlinePathY = underlinePathY * (1.0 - t) + idealY * t
                        }
                        
                        let point = PKStrokePoint(location: CGPoint(x: letter.bounds.midX,
                                                                    y: underlinePathY),
                                                  timeOffset: TimeInterval(),
                                                  size: CGSize(width: 3, height: 3),
                                                  opacity: 1.0, force: 1.0,
                                                  azimuth: 0.0, altitude: 0.0)
                        underlinePath.append(point)
                    }
                    
                    // strikethrough path logging
                    if isStrikethrough {
                        let idealY = letter.bounds.midY
                        if strikethroughPathY == 0 {
                            strikethroughPathY = idealY
                        } else {
                            strikethroughPathY += CGFloat.random(in: -2...2)
                            let t: CGFloat = 0.1
                            strikethroughPathY = strikethroughPathY * (1.0 - t) + idealY * t
                        }
                        
                        let point = PKStrokePoint(location: CGPoint(x: letter.bounds.midX,
                                                                    y: strikethroughPathY),
                                                  timeOffset: TimeInterval(),
                                                  size: CGSize(width: 3, height: 3),
                                                  opacity: 1.0, force: 1.0,
                                                  azimuth: 0.0, altitude: 0.0)
                        strikethroughPath.append(point)
                    }
                    
                } else {
                    x_pos += Float(space_length)
                }
            }
            
            
            //increment progress counter and char_i
            generated += 1
            char_i = self.text.index(after: char_i)
            updateProgress(Double(generated)/Double(self.text.count), true, false)
            
            if char_i == self.text.endIndex {
                pasteWord()
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

//
//  Extensions.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 6/30/21.
//

import Foundation
import SwiftUI
import Photos
import PencilKit

extension UIImage {
    func cropAlpha(cropVertical: Bool, cropHorizontal: Bool) -> UIImage {
        // modified from answer to https://stackoverflow.com/questions/9061800/how-do-i-autocrop-a-uiimage by Sahil Kapoor
        
        let cgImage = self.cgImage!;
        
        let width = cgImage.width
        let height = cgImage.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel:Int = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
            let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
                return self
        }
        
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var minX = width
        var minY = height
        var maxX: Int = 0
        var maxY: Int = 0
        
        for x in 1 ..< width {
            for y in 1 ..< height {
                
                let i = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                let a = CGFloat(ptr[i + 3]) / 255.0
                
                if(a>0) {
                    if (x < minX) { minX = x };
                    if (x > maxX) { maxX = x };
                    if (y < minY) { minY = y};
                    if (y > maxY) { maxY = y};
                }
            }
        }
        
        if !cropVertical {
            minY = 0
            maxY = cgImage.height
        }
        if !cropHorizontal {
            minX = 0
            maxX = cgImage.width
        }
        let rect = CGRect(x: CGFloat(minX),y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        let imageScale:CGFloat = self.scale
        let croppedImage =  self.cgImage!.cropping(to: rect)!
        let ret = UIImage(cgImage: croppedImage, scale: imageScale, orientation: self.imageOrientation)
        
        return ret;
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        if offset >= 0 {
            return self[index(startIndex, offsetBy: offset)]
        } else {
            return self[index(startIndex, offsetBy: self.count + offset)]
        }
    }
    
    func removeExtension(_ ext:String) -> String {
        var s = String(self)
        s.removeLast(ext.count)
        return s
    }
}

extension PHPhotoLibrary {
    static func checkPhotoSavePermission() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
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
}

extension PKDrawing {
    func thickened(factor: CGFloat) -> PKDrawing {
        var newStrokes = [PKStroke]()
        for stroke in self.strokes {
            var newPoints = [PKStrokePoint]()
            stroke.path.forEach { (point) in
                let newPoint = PKStrokePoint(location: point.location,
                                             timeOffset: point.timeOffset,
                                             size: CGSize(width: point.size.width * factor, height: point.size.height * factor),
                                             opacity: point.opacity,
                                             force: point.force,
                                             azimuth: point.azimuth,
                                             altitude: point.altitude)
                newPoints.append(newPoint)
            }
            let newPath = PKStrokePath(controlPoints: newPoints, creationDate: Date())
            var newStroke = PKStroke(ink: stroke.ink, path: newPath)
            newStroke.transform = stroke.transform
            newStrokes.append(newStroke)
        }
        
        return PKDrawing(strokes: newStrokes)
    }
}

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

extension UIPasteboard.Name {
    static let t2h = UIPasteboard.Name(rawValue: "text2handwritingpasteboard")
}

extension Text {
    func textborder(offset: CGFloat, color: Color) -> some View {
        self
            .background(
                ZStack {
                    ZStack {
                        self.offset(x: -offset, y: -offset)
                        self.offset(x: offset, y: -offset)
                        self.offset(x: -offset, y: offset)
                        self.offset(x: offset, y: offset)
                        self.offset(x: 0, y: -offset)
                        self.offset(x: 0, y: -offset)
                        self.offset(x: -offset, y: 0)
                        self.offset(x: offset, y: 0)
                    }
                    
                    ZStack {
                        self.offset(x: -2*offset, y: -2*offset)
                        self.offset(x: 2*offset, y: -2*offset)
                        self.offset(x: -2*offset, y: 2*offset)
                        self.offset(x: 2*offset, y: 2*offset)
                        self.offset(x: 0, y: -2*offset)
                        self.offset(x: 0, y: -2*offset)
                        self.offset(x: -2*offset, y: 0)
                        self.offset(x: 2*offset, y: 0)
                    }
                }
                    .foregroundColor(color)
            )
    }
}

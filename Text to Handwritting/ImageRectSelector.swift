//
//  ImageRectSelector.swift
//  Text to Handwriting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct ImageRectSelector: View {
    @Binding var document: TemplateDocument
    let scale: Double
    
    @State var selectedCorner: Corners?
    enum Corners: Identifiable {
        case topLeft, topRight, bottomLeft, bottomRight, fullRect
        var id: Int {
            hashValue
        }
    }
    
    @State var initial_rel_dist: CGPoint?
    
    var body: some View {
        Image(uiImage: document.object.getBackground())
            .border(Color.black, width: 2)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { pos in
                        if selectedCorner == nil {
                            let toTopLeft = sqrt(pow(pos.location.x - document.object.margins.minX,2) + pow(pos.location.y - document.object.margins.minY,2))
                            let toTopRight = sqrt(pow(pos.location.x - document.object.margins.maxX,2) + pow(pos.location.y - document.object.margins.minY,2))
                            let toBottomLeft = sqrt(pow(pos.location.x - document.object.margins.minX,2) + pow(pos.location.y - document.object.margins.maxY,2))
                            let toBottomRight = sqrt(pow(pos.location.x - document.object.margins.maxX,2) + pow(pos.location.y - document.object.margins.maxY,2))
                            let closest = min(toTopLeft, min(toTopRight, min(toBottomLeft, toBottomRight)))
                            if closest > CGFloat(25) / CGFloat(scale) {
                                selectedCorner = .fullRect
                            }
                            else if closest == toTopLeft {
                                selectedCorner = .topLeft
                            }
                            else if closest == toTopRight {
                                selectedCorner = .topRight
                            }
                            else if closest == toBottomLeft {
                                selectedCorner = .bottomLeft
                            }
                            else if closest == toBottomRight {
                                selectedCorner = .bottomRight
                            }
                            initial_rel_dist = CGPoint(x: document.object.margins.origin.x - pos.location.x, y: document.object.margins.origin.y - pos.location.y)
                        }
                        var rect2: CGRect?
                        switch selectedCorner {
                        case .topLeft:
                            rect2 = CGRect(x: pos.location.x, y: pos.location.y, width: document.object.margins.size.width + (document.object.margins.origin.x - pos.location.x), height: document.object.margins.size.height + (document.object.margins.origin.y - pos.location.y))
                        case .topRight:
                            rect2 = CGRect(x: document.object.margins.origin.x, y: pos.location.y, width: pos.location.x - document.object.margins.origin.x, height: document.object.margins.size.height + (document.object.margins.origin.y - pos.location.y))
                        case .bottomLeft:
                            rect2 = CGRect(x: pos.location.x, y: document.object.margins.origin.y, width: document.object.margins.size.width + (document.object.margins.origin.x - pos.location.x), height: pos.location.y - document.object.margins.origin.y)
                        case.bottomRight:
                            rect2 = CGRect(x: document.object.margins.origin.x, y: document.object.margins.origin.y, width: pos.location.x - document.object.margins.origin.x, height: pos.location.y - document.object.margins.origin.y)
                        case .fullRect:
                            rect2 = CGRect(x: pos.location.x + initial_rel_dist!.x, y: pos.location.y + initial_rel_dist!.y, width: document.object.margins.width, height: document.object.margins.height)
                        case .none:
                            print("This should never happen. The selected corner is somehow null, despite having been just set.")
                        }
                        document.object.margins = closest_valid_rect(oldRect: document.object.margins, newRect: rect2!, boundingRect: CGRect(x: 0, y: 0, width: document.object.getBackground().size.width, height: document.object.getBackground().size.height), minSize: CGSize(width: 50, height: 50), dragging: selectedCorner!)
                    }
                    .onEnded {_ in
                        selectedCorner = nil
                    }
            )
            .overlay(
                Rectangle()
                    .stroke(Color.red, lineWidth: CGFloat(5)/CGFloat(scale))
                    .frame(width: document.object.margins.width, height: document.object.margins.height)
                    .overlay(
                        VStack(alignment: .center, spacing: CGFloat(document.object.fontSize)) {
                            ForEach(0..<max(1,Int(document.object.margins.height/(CGFloat(document.object.fontSize)))) + 1, id: \.self) {i in
                                Rectangle()
                                    .stroke(Color.red, lineWidth: CGFloat(1)/CGFloat(scale))
                                    .frame(width: document.object.margins.width, height: 1)
                            }
                        }
                        .frame(width: document.object.margins.width, height: document.object.margins.height, alignment: .top)
                        .clipped()
                    )
                    .position(x: document.object.margins.midX, y: document.object.margins.midY)
            )
            .onChange(of: document.object.background) { _ in
                document.object.margins = CGRect(origin: CGPoint(x: 0, y: 0), size: document.object.getBackground().size)
            }
    }
    
    
    func closest_valid_rect(oldRect: CGRect, newRect: CGRect, boundingRect: CGRect, minSize: CGSize, dragging: Corners) -> CGRect{
        //logic that deals with constraining the CGRect to a real rectangle with positive area. Could be condensed, but this is by far the clearest way to write it.
        var resultRect = newRect
        
        //width check
        if resultRect.size.width < minSize.width {
            if dragging == .bottomLeft || dragging == .topLeft {
                resultRect.origin.x = oldRect.maxX - minSize.width
            }
            resultRect.size.width = minSize.width
        } else {
            // only execute side code if minimum width check is false to prevent inter-check fighting
            if resultRect.minX < boundingRect.minX {
                if dragging == .fullRect {
                    resultRect.size.width = oldRect.width
                } else {
                    resultRect.size.width = oldRect.width + (oldRect.minX - boundingRect.minX)
                }
                resultRect.origin.x = boundingRect.minX
            }
            if resultRect.maxX > boundingRect.maxX {
                if dragging == .fullRect {
                    resultRect.origin.x = boundingRect.maxX - oldRect.width
                    resultRect.size.width = oldRect.width
                } else {
                    resultRect.size.width = boundingRect.maxX - oldRect.minX
                }
            }
        }
        
        // height check
        if resultRect.size.height < minSize.height {
            if dragging == .topLeft || dragging == .topRight {
                resultRect.origin.y = oldRect.maxY - minSize.height
            }
            resultRect.size.height = minSize.height
        } else {
            // only execute side code if minimum height check is false to prevent inter-check fighting
            if resultRect.minY < boundingRect.minY {
                if dragging == .fullRect {
                    resultRect.size.height = oldRect.height
                } else {
                    resultRect.size.height = oldRect.height + (oldRect.minY - boundingRect.minY)
                }
                resultRect.origin.y = boundingRect.minY
            }
            if newRect.maxY > boundingRect.maxY {
                if dragging == .fullRect {
                    resultRect.origin.y = boundingRect.maxY - oldRect.height
                    resultRect.size.height = oldRect.height
                } else {
                    resultRect.size.height = boundingRect.maxY - oldRect.minY
                }
            }
        }
        
        return resultRect
    }
}

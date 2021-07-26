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
    
    @State var selectedCorner: Corners?
    enum Corners: Identifiable {
        case topLeft, topRight, bottomLeft, bottomRight, fullRect
        var id: Int {
            hashValue
        }
    }
    
    @State var displayScale = 0.5
    @State var initial_rel_dist: CGPoint?
    
    var body: some View {
        Image(uiImage: document.template.getBackground())
            .border(Color.black, width: 2)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { pos in
                        if selectedCorner == nil {
                            let toTopLeft = sqrt(pow(pos.location.x - document.template.margins.minX,2) + pow(pos.location.y - document.template.margins.minY,2))
                            let toTopRight = sqrt(pow(pos.location.x - document.template.margins.maxX,2) + pow(pos.location.y - document.template.margins.minY,2))
                            let toBottomLeft = sqrt(pow(pos.location.x - document.template.margins.minX,2) + pow(pos.location.y - document.template.margins.maxY,2))
                            let toBottomRight = sqrt(pow(pos.location.x - document.template.margins.maxX,2) + pow(pos.location.y - document.template.margins.maxY,2))
                            let closest = min(toTopLeft, min(toTopRight, min(toBottomLeft, toBottomRight)))
                            if closest > 25 {
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
                            initial_rel_dist = CGPoint(x: document.template.margins.origin.x - pos.location.x, y: document.template.margins.origin.y - pos.location.y)
                        }
                        var rect2: CGRect?
                        switch selectedCorner {
                        case .topLeft:
                            rect2 = CGRect(x: pos.location.x, y: pos.location.y, width: document.template.margins.size.width + (document.template.margins.origin.x - pos.location.x), height: document.template.margins.size.height + (document.template.margins.origin.y - pos.location.y))
                        case .topRight:
                            rect2 = CGRect(x: document.template.margins.origin.x, y: pos.location.y, width: pos.location.x - document.template.margins.origin.x, height: document.template.margins.size.height + (document.template.margins.origin.y - pos.location.y))
                        case .bottomLeft:
                            rect2 = CGRect(x: pos.location.x, y: document.template.margins.origin.y, width: document.template.margins.size.width + (document.template.margins.origin.x - pos.location.x), height: pos.location.y - document.template.margins.origin.y)
                        case.bottomRight:
                            rect2 = CGRect(x: document.template.margins.origin.x, y: document.template.margins.origin.y, width: pos.location.x - document.template.margins.origin.x, height: pos.location.y - document.template.margins.origin.y)
                        case .fullRect:
                            rect2 = CGRect(x: pos.location.x + initial_rel_dist!.x, y: pos.location.y + initial_rel_dist!.y, width: document.template.margins.width, height: document.template.margins.height)
                        case .none:
                            print("This should never happen. The selected corner is somehow null, despite having been just set.")
                        }
                        document.template.margins = closest_valid_rect(oldRect: document.template.margins, newRect: rect2!, boundingRect: CGRect(x: 0, y: 0, width: document.template.getBackground().size.width, height: document.template.getBackground().size.height), minSize: CGSize(width: 50, height: 50))
                    }
                    .onEnded {_ in
                        selectedCorner = nil
                    }
            )
            .overlay(
                Rectangle()
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: document.template.margins.width, height: document.template.margins.height)
                    .overlay(
                        VStack(alignment: .center, spacing: CGFloat(document.template.font_size)) {
                            ForEach(1..<max(1,Int(document.template.margins.height/(CGFloat(document.template.font_size)))), id: \.self) {i in
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 1)
                                    .frame(width: document.template.margins.width, height: 1)
                            }
                        }
                        .frame(width: document.template.margins.width, height: document.template.margins.height)
                        .clipped()
                    )
                    .position(x: document.template.margins.midX, y: document.template.margins.midY)
            )
            .scaleEffect(CGFloat(displayScale))
            .onAppear(perform: {
                displayScale = Double(min(
                    UIScreen.main.bounds.size.width/document.template.getBackground().size.width,
                    UIScreen.main.bounds.size.height/document.template.getBackground().size.height
                )) * 0.7
            })
            .onChange(of: document.template.background) { _ in
                displayScale = Double(min(
                    UIScreen.main.bounds.size.width/document.template.getBackground().size.width,
                    UIScreen.main.bounds.size.height/document.template.getBackground().size.height
                )) * 0.7
            }
    }
    
    
    func closest_valid_rect(oldRect: CGRect, newRect: CGRect, boundingRect: CGRect, minSize: CGSize) -> CGRect{
        //logic that deals with constraining the CGRect to a real rectangle with positive area. Could be condensed, but this is by far the clearest way to write it.
        var resultRect = newRect
        if resultRect.minX < boundingRect.minX {
            resultRect.origin.x = 0
            resultRect.size.width = oldRect.width
        }
        if resultRect.minY < boundingRect.minY {
            resultRect.origin.y = 0
            resultRect.size.height = oldRect.height
        }
        if resultRect.maxX > boundingRect.maxX {
            resultRect.origin.x = boundingRect.maxX - oldRect.width
            resultRect.size.width = oldRect.width
        }
        if newRect.maxY > boundingRect.maxY {
            resultRect.origin.y = boundingRect.maxY - oldRect.height
            resultRect.size.height = oldRect.height
        }
        if resultRect.size.width < minSize.width {
            resultRect.origin.x = oldRect.origin.x
            resultRect.size.width = minSize.width
        }
        if resultRect.size.height < minSize.height {
            resultRect.origin.y = oldRect.origin.y
            resultRect.size.height = minSize.height
        }
        return resultRect
    }
}

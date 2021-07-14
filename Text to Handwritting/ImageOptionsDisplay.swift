//
//  ImageOptionsDisplay.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/14/21.
//

import Foundation
import SwiftUI

struct ImageOptionsDisplay: View {
    @Binding var image: UIImage?
    
    @State var selectedCorner: Corners?
    enum Corners: Identifiable {
        case topLeft, topRight, bottomLeft, bottomRight, fullRect
        var id: Int {
            hashValue
        }
    }
    
    @Binding var rect: CGRect
    @Binding var real_rect: CGRect?
    @Binding var font_size: Float
    @State var display_scale = 0.5
    @State var initial_rel_dist: CGPoint?
    
    var body: some View {
        let width = Double(image!.size.width) * display_scale
        let height = Double(image!.size.height) * display_scale
        return Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 500)
            .border(Color.black, width: 2)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { pos in
                        if selectedCorner == nil {
                            let toTopLeft = sqrt(pow(pos.location.x - rect.minX,2) + pow(pos.location.y - rect.minY,2))
                            let toTopRight = sqrt(pow(pos.location.x - rect.maxX,2) + pow(pos.location.y - rect.minY,2))
                            let toBottomLeft = sqrt(pow(pos.location.x - rect.minX,2) + pow(pos.location.y - rect.maxY,2))
                            let toBottomRight = sqrt(pow(pos.location.x - rect.maxX,2) + pow(pos.location.y - rect.maxY,2))
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
                            initial_rel_dist = CGPoint(x: rect.origin.x - pos.location.x, y: rect.origin.y - pos.location.y)
                        }
                        var rect2: CGRect?
                        switch selectedCorner {
                        case .topLeft:
                            rect2 = CGRect(x: pos.location.x, y: pos.location.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: rect.size.height + (rect.origin.y - pos.location.y))
                        case .topRight:
                            rect2 = CGRect(x: rect.origin.x, y: pos.location.y, width: pos.location.x - rect.origin.x, height: rect.size.height + (rect.origin.y - pos.location.y))
                        case .bottomLeft:
                            rect2 = CGRect(x: pos.location.x, y: rect.origin.y, width: rect.size.width + (rect.origin.x - pos.location.x), height: pos.location.y - rect.origin.y)
                        case.bottomRight:
                            rect2 = CGRect(x: rect.origin.x, y: rect.origin.y, width: pos.location.x - rect.origin.x, height: pos.location.y - rect.origin.y)
                        case .fullRect:
                            rect2 = CGRect(x: pos.location.x + initial_rel_dist!.x, y: pos.location.y + initial_rel_dist!.y, width: rect.width, height: rect.height)
                        case .none:
                            print("This should never happen. The selected corner is somehow null, despite having been just set.")
                        }
                        rect = closest_valid_rect(oldRect: rect, newRect: rect2!, boundingRect: CGRect(x: 0, y: 0, width: width, height: height), minSize: CGSize(width: 50, height: 50))
                        update_real_rect()
                    }
                    .onEnded {_ in
                        selectedCorner = nil
                    }
            )
            .overlay(
                Rectangle()
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .overlay(
                        VStack(alignment: .center, spacing: CGFloat(Double(font_size)*display_scale)) {
                            ForEach(1..<max(1,Int(rect.height/(CGFloat(Double(font_size)*display_scale)))), id: \.self) {i in
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 1)
                                    .frame(width: rect.width, height: 1)
                            }
                        }
                        .frame(width: rect.width, height: rect.height)
                        .clipped()
                        .offset(x: CGFloat(-width*0.5) + rect.width/2 + rect.origin.x,
                                y: CGFloat(-height*0.5) + rect.height/2 + rect.origin.y)
                    )
            )
            .onAppear(perform: {
                display_scale = 500/Double(image!.size.width)
                rect = CGRect(x: Int(rect.origin.x * CGFloat(display_scale)),
                              y: Int(rect.origin.y * CGFloat(display_scale)),
                              width: Int(rect.width * CGFloat(display_scale)),
                              height: Int(rect.height * CGFloat(display_scale)))
                update_real_rect()
            })
    }
    
    func update_real_rect() {
        real_rect = CGRect(x: Int(rect.origin.x / CGFloat(display_scale)),
                           y: Int(rect.origin.y / CGFloat(display_scale)),
                           width: Int(rect.width / CGFloat(display_scale)),
                           height: Int(rect.height / CGFloat(display_scale)))
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

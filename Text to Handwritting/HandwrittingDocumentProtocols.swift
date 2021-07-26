//
//  HandwrittingDocumentProtocols.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/26/21.
//

import Foundation
import SwiftUI

protocol HandwritingDocument {
    static var defaultSaveFile: String { get }
    static var fileExtension: String { get }
    associatedtype ObjectType: Equatable, Codable, HandwritingDocumentResource
    var object: ObjectType { get set }
    static func createNew(path: URL)
    init(from: Data)
}

protocol HandwritingDocumentResource {
    func getPreview() -> UIImage
    func isCompleteFor(text: String) -> Bool
}

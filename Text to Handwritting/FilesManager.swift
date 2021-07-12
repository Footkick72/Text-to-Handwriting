//
//  FilesManager.swift
//  Text to Handwritting
//
//  Created by Daniel Long on 7/11/21.
//

import Foundation

//code copied from https://www.iosapptemplates.com/blog/ios-development/data-persistence-ios-swift FileManager example

class FilesManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
        case fileNotExists
    }
    let fileManager: FileManager
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    func save(fileNamed: String, data: Data) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            try data.write(to: url)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func read(fileNamed: String) throws -> Data {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        if let path = paths.first {
            let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileNamed)
            do { return try Data(contentsOf: fileURL) } catch { throw Error.fileNotExists }
        }
        throw Error.invalidDirectory
    }
    
    func delete(fileNamed: String) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        try fileManager.removeItem(at: url)
    }
}

//
//  PlistDocument.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/18.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit

/// 它实现了一个UIDocument的派生类PlistDocument
/// 定义了 save 和 read 文件时的必要方法
class PlistDocument: UIDocument {
    var plistData: NSData!
    
    init(fileURL: URL, data: NSData) {
        super.init(fileURL: fileURL)
        
        plistData = data
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return plistData
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? NSData {
            plistData = userContent
        }
    }
}

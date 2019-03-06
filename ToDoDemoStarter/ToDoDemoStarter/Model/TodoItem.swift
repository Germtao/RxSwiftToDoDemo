//
//  TodoItem.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/12.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit

// MARK: - 遵从NSCoding的类, 便于序列化成 plist 保存和加载
class TodoItem: NSObject, NSCoding {
    
    /// 表示每一个todo对应的图片名, 默认 空
    var pictureMemoFileName = ""
    
    private let kName = "Name"
    private let kIsFinished = "isFinished"
    
    /// todo标题
    var name: String = ""
    /// 是否完成, 默认 false
    var isFinished: Bool = false
    
    override init() {
        super.init()
    }
    
    init(name: String, isFinished: Bool) {
        self.name = name
        self.isFinished = isFinished
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: kName)
        aCoder.encode(isFinished, forKey: kIsFinished)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: kName) as! String
        isFinished = aDecoder.decodeBool(forKey: kIsFinished)
        
        super.init()
    }
    
    func toggleFinished() {
        isFinished = !isFinished
    }
}

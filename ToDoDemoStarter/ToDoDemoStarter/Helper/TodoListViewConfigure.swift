//
//  TodoListViewConfigure.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/18.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit
import RxSwift

let plistPath = "Documents/TodoList.plist"

enum SaveTodoError: Error {
    case cannotSaveToLocalFile
    case iCloudIsNotEnable
    case cannotReadLocalFile
    case cannotCreateFileOnCloud
}

extension TodoListViewController {
    /// 同步任务到iCloud
    func syncTodoToCloud() {
        guard let cloudUrl = ubiquityURL(plistPath) else {
            flash(title: "失败", message: "请设置iCloud可用！")
            return
        }
        guard let localData = NSData(contentsOf: dataFilePath()) else {
            flash(title: "失败", message: "不能加载本地文件！")
            return
        }
        
        let plist = PlistDocument(fileURL: cloudUrl, data: localData)
        plist.save(to: cloudUrl, for: .forOverwriting) { (success: Bool) in
            print(cloudUrl)
            if success {
                self.flash(title: "成功", message: "所有的任务已同步到cloud！")
            } else {
                self.flash(title: "失败", message: "任务同步到cloud失败！")
            }
        }
    }
}

// MARK: - 数据处理
extension TodoListViewController {
    /// 加载todoItems
    func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems.value = unarchiver.decodeObject(forKey: TODO_ITEMS_KEY) as! [TodoItem]
            unarchiver.finishDecoding()
        }
    }
    
    /// 保存todoItems, 返回一个 自定义事件序列
    func saveTodoItems() -> Observable<Void> {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(todoItems.value, forKey: TODO_ITEMS_KEY)
        archiver.finishEncoding()
        
        return Observable.create({ (observer) -> Disposable in
            // data.write(to:atomically:)方法是有可能执行失败的，失败的时候，它会返回false
            let result = data.write(to: self.dataFilePath(), atomically: true)
            if result {
                observer.onCompleted()
            } else {
                observer.onError(SaveTodoError.cannotSaveToLocalFile)
            }
            return Disposables.create()
        })
    }
}

// MARK: - Helper Func
extension TodoListViewController {
    private func ubiquityURL(_ filename: String) -> URL? {
        guard let ubiquityURL =
            FileManager.default.url(forUbiquityContainerIdentifier: nil) else { return nil }
        return ubiquityURL.appendingPathComponent("filename")
    }
    
    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
}

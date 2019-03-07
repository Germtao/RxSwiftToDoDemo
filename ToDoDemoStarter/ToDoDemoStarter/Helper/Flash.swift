//
//  Flash.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/18.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit

extension TodoListViewController {
    typealias AlertCallback = ((UIAlertAction) -> Void)
    /// 用于在操作完成后，给用户一个提示
    func flash(title: String, message: String, callback: AlertCallback? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: callback)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoCollectionViewController {
    typealias AlertCallback = ((UIAlertAction) -> Void)
    /// 用于在操作完成后，给用户一个提示
    func flash(title: String, message: String, callback: AlertCallback? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: callback)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

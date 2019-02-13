//
//  TodoDetailViewController.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/12.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit
import RxSwift

class TodoDetailViewController: UITableViewController {
    
    /// 作为Observer, 发布事件给订阅者
    private let todoSubject = PublishSubject<TodoItem>()
    /// 作为Observerable, 订阅外部发送的事件
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    /// 1. 回收
    var bag = DisposeBag()
    
    var todoItem: TodoItem!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var finishedSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        todoName.becomeFirstResponder()
        if let todoItem = todoItem {
            self.todoItem.name = todoItem.name
            self.todoItem.isFinished = todoItem.isFinished
        } else {
            todoItem = TodoItem()
        }
        
        print("Resource tracing: \(RxSwift.Resources.total)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 2. 主流方法: 对于一个Observable来说，除了所有订阅者都取消订阅会导致其被回收之外，
        //            Observable自然结束（onCompleted）或发生错误结束（onError）也会自动让所有订阅者取消订阅，
        //            并导致Observable占用的资源被回收
        todoSubject.onCompleted()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        todoItem.name = todoName.text!
        todoItem.isFinished = finishedSwitch.isOn
        // subject作为Observer发送事件
        todoSubject.onNext(todoItem)
        dismiss(animated: true, completion: nil)
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension TodoDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneItem.isEnabled = newText.length > 0
        
        return true
    }
}

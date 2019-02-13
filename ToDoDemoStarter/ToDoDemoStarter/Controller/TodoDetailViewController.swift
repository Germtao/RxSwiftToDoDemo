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
        todoItem = TodoItem()
        
        print("Resource tracing: \(RxSwift.Resources.total)")
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

//
//  TodoListViewController.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/12.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit
import RxSwift

let kTodoCellID = "TodoItem"
let CELL_TODO_TITLE_TAG = 1002
let CELL_CHECKMARK_TAG = 1001
let TODO_ITEMS_KEY = "TodoItems"

class TodoListViewController: UIViewController {
    
    let todoItems = Variable<[TodoItem]>([])  // 变成Variable
    let bag = DisposeBag()  // 用于回收取消订阅的DisposeBag对象

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var addItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // 由于todoItems是一个Subject，作为一个observer，我们修改它的值，就相当于它自己订阅到了事件
        // 而要响应值的修改，我们就把它当作一个observable直接订阅就好了
        todoItems.asObservable().subscribe(onNext: { [weak self] todos in
            // update UI
            self?.updateUI(todos: todos)
        }).disposed(by: bag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadTodoItems()
    }
    
    @IBAction func addTodoItem(_ sender: UIBarButtonItem) {
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
        todoItems.value.append(todoItem)
    }
    
    @IBAction func clearTodoList(_ sender: UIButton) {
        todoItems.value.removeAll()
    }
    
    @IBAction func saveTodoList(_ sender: UIButton) {
        saveTodoItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        let currVc = nav.topViewController as! TodoDetailViewController
        
        if segue.identifier == "AddTodo" {
            currVc.title = "Add Todo"
            // 实现订阅事件
            currVc.todo.subscribe(onNext: { [weak self] (newTodo) in
                self?.todoItems.value.append(newTodo)
            }) {
                print("Finish adding a new todo")
            }.disposed(by: currVc.bag)
        } else if segue.identifier == "EditTodo" {
            currVc.title = "Edit Todo"
        }
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let todo = todoItems.value[indexPath.row]
            todo.toggleFinished()
            configureStatus(for: cell, with: todo)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todoItems.value.remove(at: indexPath.row)
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTodoCellID, for: indexPath)
        let todo = todoItems.value[indexPath.row]
        
        configureLabel(for: cell, with: todo)
        configureStatus(for: cell, with: todo)
        
        return cell
    }
}

// MARK: - 配置cell & 更新UI
extension TodoListViewController {
    private func configureLabel(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_TODO_TITLE_TAG) as! UILabel
        label.text = item.name
    }
    
    private func configureStatus(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_CHECKMARK_TAG) as! UILabel
        label.text = item.isFinished ? "✅" : ""
    }
    
    private func updateUI(todos: [TodoItem]) {
        tableView.reloadData()
    }
}

// MARK: - 数据处理
extension TodoListViewController {
    /// 加载todoItems
    private func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems.value = unarchiver.decodeObject(forKey: TODO_ITEMS_KEY) as! [TodoItem]
            unarchiver.finishDecoding()
        }
    }
    
    /// 保存todoItems
    private func saveTodoItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(todoItems.value, forKey: TODO_ITEMS_KEY)
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    
    private func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    private func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TodoList.plist")
    }
}


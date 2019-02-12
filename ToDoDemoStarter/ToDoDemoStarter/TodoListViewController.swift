//
//  TodoListViewController.swift
//  ToDoDemoStarter
//
//  Created by TT on 2019/2/12.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit

let kTodoCellID = "TodoItem"
let CELL_TODO_TITLE_TAG = 1002
let CELL_CHECKMARK_TAG = 1001
let TODO_ITEMS_KEY = "TodoItems"

class TodoListViewController: UIViewController {
    
    var todoItems: [TodoItem] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var addItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        todoItems = [TodoItem]()
        super.init(coder: aDecoder)
        loadTodoItems()
        
    }
    
    @IBAction func addTodoItem(_ sender: UIBarButtonItem) {
        let newRowIndex = todoItems.count
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
        todoItems.append(todoItem)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func clearTodoList(_ sender: UIButton) {
        todoItems = [TodoItem]()
        tableView.reloadData()
    }
    
    @IBAction func saveTodoList(_ sender: UIButton) {
        saveTodoItems()
    }
}

extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let todo = todoItems[indexPath.row]
            todo.toggleFinished()
            configureStatus(for: cell, with: todo)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todoItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTodoCellID, for: indexPath)
        let todo = todoItems[indexPath.row]
        
        configureLabel(for: cell, with: todo)
        configureStatus(for: cell, with: todo)
        
        return cell
    }
}

// MARK: - 配置cell
extension TodoListViewController {
    private func configureLabel(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_TODO_TITLE_TAG) as! UILabel
        label.text = item.name
    }
    
    private func configureStatus(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_CHECKMARK_TAG) as! UILabel
        label.text = item.isFinished ? "✅" : ""
    }
}

// MARK: - 数据处理
extension TodoListViewController {
    /// 加载todoItems
    private func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems = unarchiver.decodeObject(forKey: TODO_ITEMS_KEY) as! [TodoItem]
            unarchiver.finishDecoding()
        }
    }
    
    /// 保存todoItems
    private func saveTodoItems() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(todoItems, forKey: TODO_ITEMS_KEY)
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


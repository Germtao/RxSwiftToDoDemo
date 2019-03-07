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
    
    private var todoCollage: UIImage?
    @IBOutlet weak var memoCollageBtn: UIButton!
    
    /// 作为Observer, 发布事件给订阅者
    private let todoSubject = PublishSubject<TodoItem>()
    /// 作为Observerable, 订阅外部发送的事件
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    /// 1. 回收
    var bag = DisposeBag()
    
    /// Variable 值类型 [UIImage], 用来保存用户选中的所有图片
    private let images = Variable<[UIImage]>([])
    
    var todoItem: TodoItem!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var finishedSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoName.becomeFirstResponder()
        
        // 让image是一个Observable，我们订阅它的值并更新UI
        images.asObservable().subscribe(onNext: { [weak self] (images) in
            guard let `self` = self else { return }
            guard !images.isEmpty else {
                self.resetMemoButton()
                return
            }
            
            self.todoCollage = UIImage.collage(images: images, in: self.memoCollageBtn.frame.size)
            self.setMemoButton(with: self.todoCollage ?? UIImage())
        }).disposed(by: bag)
        
        /**
         订阅后的处理逻辑很简单，就像代码注释中说明的那样，分成两个步骤:
         
             1. 合成所有用户选择的图片
             2. 把合成后的图片设置为按钮的背景
         */
        
        if let todoItem = todoItem {
            self.todoName.text = todoItem.name
            self.finishedSwitch.isOn = todoItem.isFinished
            
            if todoItem.pictureMemoFileName != "" {
                let url = getDocumentsDir().appendingPathComponent(todoItem.pictureMemoFileName)
                if let data = try? Data(contentsOf: url) {
                    memoCollageBtn.setBackgroundImage(UIImage(data: data), for: .normal)
                    memoCollageBtn.setTitle("", for: .normal)
                }
            }
            
            doneItem.isEnabled = true
            
        } else {
            todoItem = TodoItem()
        }
        
        print("Resource tracing: \(RxSwift.Resources.total)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoCollectionVc = segue.destination as! PhotoCollectionViewController
        images.value.removeAll()
        resetMemoButton()
        
        let selectedPhotos = photoCollectionVc.selectedPhotos.share()  // 多次订阅时共享事件
        
        // 从selectedPhotos中订阅到用户选择的所有图片
        /**
         scan的初始值是一个空的数组，然后selectedPhotos中每发生一次图片选中事件，
         我们就检查图片是否已经添加过了，如果加过就删掉，否则就添加进来。处理完之后，我们把当前所有合并的[UIImage]返回
        */
        selectedPhotos.scan([]) { (photos: [UIImage], newPhoto) in
            var newPhotos = photos
            
            if let index = newPhotos.firstIndex(where: { UIImage.isEqual(lhs: newPhoto, rhs: $0) }) {
                newPhotos.remove(at: index)
            } else {
                newPhotos.append(newPhoto)
            }
            return newPhotos
        }.subscribe(onNext: { images in
            self.images.value = images
        }, onDisposed: {
            print("Finished choose photo memos.")
        }).disposed(by: photoCollectionVc.bag)
        
        selectedPhotos.ignoreElements().subscribe(onCompleted: {
            self.setMemoSectionHeaderText()
        }).disposed(by: photoCollectionVc.bag)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// 保存合成后的图片，并结束todoSubject序列
    @IBAction func done(_ sender: UIBarButtonItem) {
        todoItem.name = todoName.text!
        todoItem.isFinished = finishedSwitch.isOn
        todoItem.pictureMemoFileName = savePictureMemos()
        
        // subject作为Observer发送事件
        todoSubject.onNext(todoItem)
        // 2. 主流方法: 对于一个Observable来说，除了所有订阅者都取消订阅会导致其被回收之外，
        //            Observable自然结束（onCompleted）或发生错误结束（onError）也会自动让所有订阅者取消订阅，
        //            并导致Observable占用的资源被回收
        todoSubject.onCompleted()
        dismiss(animated: true, completion: nil)
    }
}

extension TodoDetailViewController {
    private func resetMemoButton() {
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("点击选择图片", for: .normal)
    }
    
    private func setMemoButton(with backgroundImage: UIImage) {
        memoCollageBtn.setBackgroundImage(backgroundImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal)
    }
    
    private func getDocumentsDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func savePictureMemos() -> String {
        if let collage = self.todoCollage, let data = collage.pngData() {
            let path = getDocumentsDir()
            let filename = todoName.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)
            
            try? data.write(to: memoImageUrl)
            
            return filename
        }
        
        return todoItem.pictureMemoFileName
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /// 设置Memo header
    private func setMemoSectionHeaderText() {
        guard !images.value.isEmpty, let header = tableView.headerView(forSection: 2) else {
            return
        }
        
        header.textLabel?.text = "\(images.value.count) MEMOS"
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

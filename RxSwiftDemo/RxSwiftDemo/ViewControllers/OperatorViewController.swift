//
//  OperatorViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit
import RxSwift

/**
 理解operators分两类:
     1. 一类用于创建 Observable - "以时间为索引的常量队列"
     2. 一类是接受Observable作为参数, 并返回一个新的Observable (Observable中的每一个元素，都可以理解为一个异步发生的事件)
 */

class OperatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        operatorEvent()
        
        dispose()
        
    }
}

// MARK: - 理解 operators
extension OperatorViewController {
    private func operatorEvent() {
        /**
         两个Operator:
         of：用固定数量的元素生成一个Observable
         from：用一个Sequence类型的对象创建一个Observable
         */
        // 1. 创建事件序列
        let ofOperator = Observable.of("1", "2", "3", "4", "5", "6", "7", "8", "9")
        let fromOperator = Observable.from(["1", "2", "3", "4", "5", "6", "7", "8", "9"])
        
        // 2. 对事件序列进行处理
        let evenNumberObservable =
            ofOperator
                .map {
                    Int($0)
                } // map就是一个可以对Observable中的元素变形的operator
                .filter { // 进一步在变形后的Observable中, 找出所有偶数
                    //                    $0 != nil && $0! % 2 == 0
                    if let item = $0, item % 2 == 0 {
                        print("Even: \(item)")
                        return true
                    }
                    return false
        }
        
        // 3. 订阅事件
        // 全程关注
        //        evenNumberObservable.subscribe { (event) in
        //            print("Event: \(event)")
        //        }
        
        // 半路关注: skip(2)可以让订阅者“错过”前2次发生的事件
        evenNumberObservable.skip(2).subscribe { (event) in
            print("Event: \(event)")
        }
        
        /**
         Cold Observable: 只有在订阅时, 才emit事件的Observable
         Hot Observable: 只要创建了就会自动emit事件的Observable
         */
    }
}

// MARK: - 理解 Observable dispose
extension OperatorViewController {
    private func dispose() {
        var bag = DisposeBag()
        
        // interval在主线程定义了一个每隔1秒发送一个整数的事件序列
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { print("Subscribe: \($0)") },
                       onDisposed: { print("The queue was disposed") })
            .disposed(by: bag)
        delay(5) {
//            disposeable.dispose()
            bag = DisposeBag()
        }
    }
    
    // MARK: - Helper
    private func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}

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
        
//        dispose()
        
        creatOperator()
        
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

// MARK: - 理解 create 和 debug operator
extension OperatorViewController {
    
    enum CustomError: Error {
        case somethingError
    }
    
    private func creatOperator() {
        
        /**
         create(<#T##subscribe: (AnyObserver<Int>) -> Disposable##(AnyObserver<Int>) -> Disposable#>)
             subscribe并不是指事件真正的订阅者，而是用来定义当有人订阅Observable中的事件时，
             应该如何向订阅者发送不同情况的事件，理解这个问题，是使用create的关键
         */
        let customOb = Observable<Int>.create { (observer) in
            observer.onNext(10)
            
            // 最后，在订阅的时候，我们可以直接通过onError来得到错误通知：
            observer.onError(CustomError.somethingError)
            
            observer.onNext(11)
            
            observer.onCompleted()
            
            return Disposables.create() // 用这个对象取消订阅进而回收customOb占用的资源
        }
        
        let bag = DisposeBag()
        //如果我们怀疑某个串联的环节发生了问题，就可以插入一个do operator进行观察
//        customOb.do(onNext: { print("Intercepted: \($0)") },
//                    onError: { print("Intercepted: \($0)") },
//                    onCompleted: { print("Intercepted: Completed") },
//                    onDispose: { print("Intercepted: Game Over") })
//            .subscribe(
//                onNext: { print($0) },
//                onError: { print($0) },
//                onCompleted: { print("Completed") },
//                onDisposed: { print("Game Over") }).disposed(by: bag)
        
        // 用do进行调试并不方便，毕竟还要写一堆的on，再配上各自的closure，应该有一个专门可以穿插在各种operator之间进行调试的operator。
        // 实际上，do也的确不是为了调试而生的，我们只是借用了它的“旁路”特性而已。
        // RxSwift提供了一个调试专属的operator，叫做debug，它可以安插在任意一个需要确认事件值的地方，像这样
        customOb.debug()
            .subscribe(
                onNext: { print($0) },
                onError: { print($0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Game Over") })
            .disposed(by: bag)
    }
}

/**
 实际上，这些带给我们异步感觉的操作，都需要在运行时动态给Observable添加内容。
 这也就意味着，这种Observable要有双重身份：
     1. 一方面，它自身得是一个订阅者以获得系统事件的通知；
     2. 另一方面，它也得是一个Observable，供我们编写的客户端代码进行订阅。
 在Rx的世界里，这样具有双重身份的对象，有一个专属的名字，叫做Subject。因此，在用更真实的方式学习RxSwift之前，我们还需要额外做些工作
 */

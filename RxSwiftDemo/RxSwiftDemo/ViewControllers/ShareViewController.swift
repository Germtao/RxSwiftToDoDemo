//
//  ShareViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/7.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit
import RxSwift

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        share_1()
        share_2()
    }
}

// MARK: - share() - 不要反复订阅同一个Observable
extension ShareViewController {
    /**
     希望这两次订阅实际上使用的是同一个Observable，但执行一下就会在控制台看到，打印了两次0 1 2 3 4 ，
     也就是说每次订阅，都会产生一个新的Observable对象，多次订阅的默认行为，并不是共享同一个序列上的事件
     */
    private func share_1() {
        let numbers = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            
            return Disposables.create()
        }
        
        let bag = DisposeBag()
        
        numbers.subscribe(onNext: { print($0) }).disposed(by: bag)
        numbers.subscribe(onNext: { print($0) }).disposed(by: bag)
    }
    
    /**
     为了在多次订阅的时候共享事件，我们可以使用share operator，为了观察这个效果，我们把numbers的定义改成这样:
     */
    private func share_2() {
        let numbers = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            
            return Disposables.create()
        }.share()
        
        let bag = DisposeBag()
        
        numbers.subscribe(onNext: { print($0) }).disposed(by: bag)
        numbers.subscribe(onNext: { print($0) }).disposed(by: bag)
    }
}

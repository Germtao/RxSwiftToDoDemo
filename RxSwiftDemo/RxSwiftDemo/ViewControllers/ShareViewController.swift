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
    
    @IBOutlet weak var label: UILabel!
    
    enum SenderText: String {
        case share = "Share"
        case share1 = "Share1"
        case toArray = "toArray"
        case toArray1 = "toArray1"
        case scan = "Scan"
        case scan1 = "Scan1"
        case map = "Map"
        case map1 = "Map1"
        case flatMap = "FlatMap"
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text,
            let senderText = SenderText(rawValue: text) else {
            fatalError("Unexpected Sender")
        }
        switch senderText {
        case .share:
            share_1()
        case .share1:
            share_2()
        case .toArray:
            toArray()
        case .toArray1:
            toArray1()
        case .scan:
            scan()
        case .scan1:
            scan1()
        case .map:
            map()
        case .map1:
            map1()
        case .flatMap: break
        }
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
        
        var string = ""
        numbers.subscribe(onNext: {
            string = string + "\n" + "\($0)"
            self.label.text = string
            print($0)
        }).disposed(by: bag)
        numbers.subscribe(onNext: {
            string = string + "\n" + "\($0)"
            self.label.text = string
            print($0)
        }).disposed(by: bag)
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
        var string = ""
        numbers.subscribe(onNext: {
            string = string + "\n" + "\($0)"
            self.label.text = string
            print($0)
        }).disposed(by: bag)
        numbers.subscribe(onNext: {
            string = string + "\n" + "\($0)"
            self.label.text = string
            print($0)
        }).disposed(by: bag)
    }
}

// MARK: - 常用的transform operators
extension ShareViewController {
    // MARK: - toArray
    private func toArray() {
        let bag = DisposeBag()
        
        Observable.of(1, 2, 3, 4)
            .toArray().subscribe(onNext: {
                // Array<Int>
                print(type(of: $0))
                // [1, 2, 3, 4]
                self.label.text = String(format: "%@", $0)
                print($0)
            }).disposed(by: bag)
    }
    
    /**
         toArray的转换，是在原始Observable结束的时候，把原始Observable中所有的事件值变成一个数组，
         只要原始Observable不结束，这个转换就不会发生
     */
    private func toArray1() {
        let bag = DisposeBag()
        let numbers = PublishSubject<Int>()
        
        numbers.asObservable()
            .toArray()
            .subscribe(onNext: {
                self.label.text = String(format: "%@", $0)
                print($0)
            })
            .disposed(by: bag)
        
        numbers.onNext(1)
        numbers.onNext(2)
        numbers.onNext(3)
        
        numbers.onCompleted()
    }
    
    // MARK: - scan
    /**
     给它设定一个初始值之后, 可以对Observable序列中的每一个事件进行'累加', 最终订阅到的, 是'累加'之后的结果
     */
    private func scan() {
        let bag = DisposeBag()
        var string = ""
        Observable.of(1, 2, 3).scan(0) { (accumulatedValue, value) in
            accumulatedValue + value
        }.subscribe(onNext: {
            string = string + "\n" + "\($0)"
            self.label.text = string
            print($0)
        }).disposed(by: bag)
        
        /**
         结果: 1   3   6  和toArray不同的是, scand在Observable每次有事件的时候都会执行
         */
    }
    
    private func scan1() {
        let bag = DisposeBag()
        var string = ""
        let numbers = PublishSubject<Int>()
        numbers.asObservable()
            .scan(0) { $0 + $1 }
            .subscribe(onNext: {
                string = string + "\n" + "\($0)"
                self.label.text = string
                print("Scan: \($0)")
            }).disposed(by: bag)
        
        numbers.onNext(1)
        numbers.onNext(1)
    }
}

// MARK: - 转换事件类型的map
extension ShareViewController {
    /**
     除了把事件进行'累加'外, 也可以更自由的定义事件变换的行为
     */
    private func map() {
        var str = ""
        Observable.of(1, 2, 3).map { (value) in
            value * 2
        }.subscribe(onNext: {
            str = str + "\n" + "\($0)"
            self.label.text = str
            print($0)
        }).dispose()
        
        /**
         结果: 2  4  6
         
         订阅到的是事件被 map 之后的Observable。map 接受一个closure, 而这个closure的参数, 就是原Observable中的事件值
         */
    }
    
    private func map1() {
        var str = ""
        Observable.of(1, 2, 3).enumerated().map { (index, value) in
            index < 1 ? value : value * 2
        }.subscribe(onNext: {
            str = str + "\n" + "\($0)"
            self.label.text = str
            print($0)
        }).dispose()
        
        /**
         结果: 1  4  6
         */
    }
}

// MARK: - FlatMap
extension ShareViewController {
    
}

//
//  SubjectViewController.swift
//  RxSwiftDemo
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 QDSG. All rights reserved.
//

import UIKit
import RxSwift

class SubjectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        publishSubject()
        
//        behaviorSubject()
        
//        replaySubject()
        
        variable()
    }
}

// MARK: - PublishSubject
extension SubjectViewController {
    /**
     PublishSubject就像个出版社，到处收集内容，
         1. 它是一个Observer，然后发布给它的订阅者
         2. 它是一个Observable
     */
    private func publishSubject() {
        // 1. 创建
        let subject = PublishSubject<String>()   // 其中PublishSubject的泛型参数，表示它可以订阅到的，以及可以发布的事件类型
        
        // 2. subject当作Observer的时候，可以使用onNext方法给它发送事件
        subject.onNext("Episode1 update")
        
        // 3. subject当作Observable的时候，订阅它的代码和订阅普通的Observable完全一样
        let sub1 = subject.subscribe(onNext: { print("Sub1 - What happened: \($0)") })
        /**
         结果: 因为PublishSubject执行的是“会员制”, 它只会把最新的消息通知给消息发生之前的订阅者, 无任何打印
         */
        
        subject.onNext("Episode2 update")
        /**
         结果: Sub1 - What happened: Episode2 update
         */
        
        sub1.dispose()
        
        let sub2 = subject.subscribe(onNext: { print("Sub2 - what happened: \($0)") })
        subject.onNext("Episode3 update")
        subject.onNext("Episode4 update")
        /**
         结果: Sub1 - What happened: Episode2 update
              Sub2 - what happened: Episode3 update
              Sub2 - what happened: Episode4 update
         */
        sub2.dispose()
    }
    
    /**
     首先，在执行过sub1.dispose()之后，sub1就不会再接收来自subject的任何消息了；
     其次，subject有了一个新的订阅者sub2；
     第三，subject又捕获到了两条新的消息。按照刚才的说法，sub2不会接收到订阅之前的消息，
          因此，我们应该只能在控制台看到 Sub2 - what happened: Episode3 updated
                                   Sub2 - what happened: Episode4 updated  这两条消息；
     最后，sub2取消对subject的订阅
     */
}

// MARK: - BehaviorSubject
extension SubjectViewController {
    /**
     如果你希望Subject从“会员制”变成“试用制”，就需要使用BehaviorSubject。
     它和PublisherSubject唯一的区别，就是只要有人订阅，它就会向订阅者发送最新的一次事件作为“试用”
     */
    private func behaviorSubject() {
        let subject = BehaviorSubject<String>(value: "RxSwift step bu step")  // 初始化一个BehaviorSubject对象的时候，要给它指定一个默认的推送消息
        
        let sub1 = subject.subscribe(onNext: { print("Sub1 - what happened \($0)") })
        
        subject.onNext("Episode1 update")
        /**
         由于BehaviorSubject有了一个默认的事件，sub1订阅之后
         
         结果: Sub1 - what happened RxSwift step bu step
              Sub1 - what happened Episode1 update
         */
        
        let sub2 = subject.subscribe(onNext: { print("Sub2 - what happened \($0)") })
        /**
         结果: Sub2 - what happened Episode1 update
         
              如果我们要让sub2在订阅的时候获取到过去所有的消息，就需要使用 ReplaySubject
         */
        sub1.dispose()
        sub2.dispose()
    }
}

// MARK: - ReplaySubject
extension SubjectViewController {
    /**
     ReplaySubject的行为和BehaviorSubject类似，都会给订阅者发送历史消息。不同地方有两点:
         1. ReplaySubject没有默认消息，订阅空的ReplaySubject不会收到任何消息
         2. ReplaySubject自带一个缓冲区，当有订阅者订阅的时候，它会向订阅者发送缓冲区内的所有消息
     */
    private func replaySubject() {
        // 1. ReplaySubject缓冲区的大小，是在创建的时候确定的
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        
        // 2. 创建了一个可以缓存两个消息的ReplaySubject。作为Observable，它此时是一个空的事件序列，订阅它，不会收到任何消息
        let sub1 = subject.subscribe(onNext: { print("Sub1 - what happened \($0)")})
        
        subject.onNext("Episode1 update")
        subject.onNext("Episode2 update")
        subject.onNext("Episode3 update")
        /**
         结果: Sub1 - what happened Episode1 update
              Sub1 - what happened Episode2 update
              Sub1 - what happened Episode3 update
         */
        
        let sub2 = subject.subscribe(onNext: { print("Sub2 - what happened \($0)") })
        /**
         由于subject缓冲区的大小是2，它会自动给sub2发送最新的两次历史事件
         
         结果: Sub2 - what happened Episode2 update
              Sub2 - what happened Episode3 update
         */
        sub1.dispose()
        sub2.dispose()
    }
}

// MARK: - Variable 后续会用 `BehaviorRelay` 替代
extension SubjectViewController {
    /**
     除了事件序列之外，在平时的编程中我们还经常需遇到一类场景，就是需要某个值是有“响应式”特性的，
     例如: 可以通过设置这个值来动态控制按钮是否禁用，是否显示某些内容等。
     为了方便这个操作，RxSwift还提供了一个特殊的subject，叫做Variable
     */
    private func variable() {
        // 1. 定义： 可以像定义一个普通变量一样定义一个Variable
        let strVariable = Variable("Episode1")
        
        // 2. 要订阅一个Variable对象的时候，要先明确使用asObservable()方法。而不像其他subject一样直接订阅
        let sub1 = strVariable
            .asObservable()
            .subscribe { print("sub1: \($0)") }
        /**
         结果: sub1: next(Episode1)
              sub1: completed
         */
        
        // 3. 而当我们要给一个Variable设置新值的时候，要明确访问它的value属性，而不是使用onNext方法
        strVariable.value = "Episode2"
        /**
         结果: sub1: next(Episode1)
              sub1: next(Episode2)
              sub1: completed
         */
    }
    
    /**
     最后要说明的一点是，Variable只用来表达一个“响应式”值的语义，因此，它有以下两点性质：
     
         1. 绝不会发生.error事件；
         2. 无需手动给它发送.complete事件表示完成
     */
}

//
//  PHPhotoLibrary+Rx.swift
//  ToDoDemoStarter
//
//  Created by QDSG on 2019/3/7.
//  Copyright © 2019 SwifterTT. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
    static var isAuthorized: Observable<Bool> {
        return Observable.create({ (observer) in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized { // 当前授权状态
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    // 申请用户授权
                    requestAuthorization({
                        observer.onNext($0 == PHAuthorizationStatus.authorized)
                        observer.onCompleted()
                    })
                }
            }
            return Disposables.create()
        })
    }
}

//
//  PhotoCollectionViewController.swift
//  ToDoDemoStarter
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 SwifterTT. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController {
    
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    let bag = DisposeBag()
    
    private lazy var photos = PhotoCollectionViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    private lazy var thumbnailsize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setCellSpace()
        
        /**
         这个过程要比我们想象的复杂一点，我们不能直接订阅isAuthorized的onNext并处理true/false的情况，因为单一的事件值并不能反映真实的授权情况。按照之前分析的:
             1. 授权成功的序列可能是：.next(true)，.completed或.next(false)，.next(true)，.completed
             2. 授权失败的序列则是：.next(false)，.next(false)，.completed
         因此，我们需要把isAuthorized这个事件序列处理一下，分别处理授权成功和失败的情况
         */
        
        // 订阅成功事件
        let isAuthorized = PHPhotoLibrary.isAuthorized
        isAuthorized.skipWhile { $0 == false }  // skipWhile和take模拟了忽略所有false并读取第一个true这个动作
            .take(1)
            .observeOn(MainScheduler.instance)  // 表示了在主线程中执行订阅代码
            .subscribe(onNext: { [weak self] _ in
            // reload the photo collection view
                if let `self` = self {
                    self.photos = PhotoCollectionViewController.loadPhotos()
                    self.collectionView.reloadData()
//                    DispatchQueue.main.async {  // 传递给requestAuthorization的closure参数有可能并不在主线程中执行，一旦如此，我们订阅的授权结果的代码也就不会在主线程中执行
//                        self.collectionView.reloadData()
//                    }
                }
            })
            .disposed(by: bag)
        
        // 订阅失败事件
        isAuthorized
            .distinctUntilChanged()
            .take(1)
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] _ in
                self?.flash(title: "不能访问相册", message: "系统设置中授权相册", callback: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
            }).disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }
}

// MARK: - Photo library
extension PhotoCollectionViewController {
    /// 获取照片数组
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
}

// MARK: - Collection View Related
extension PhotoCollectionViewController {
    /// 设置cell间隙
    func setCellSpace() {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width - 40) * 0.25, height: (width - 40) * 0.25)
        collectionView.collectionViewLayout = layout
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailsize,
                                  contentMode: .aspectFill,
                                  options: nil)
        { (image, _) in
            guard let image = image else { return }
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.selected()
        }
        
        imageManager.requestImage(for: asset,
                                  targetSize: view.frame.size,
                                  contentMode: .aspectFill,
                                  options: nil) { [weak self] (image, info) in
                                    
                                    guard let image = image, let info = info else { return }
            
                                    if let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool, !isThumbnail {
                                        // 如果图片库中的图片不是iCloud中的缩略图，则触发事件
                                        self?.selectedPhotosSubject.onNext(image)
                                    }
        }
    }
}


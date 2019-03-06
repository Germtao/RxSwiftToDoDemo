//
//  PhotoCell.swift
//  ToDoDemoStarter
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 SwifterTT. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoMemo"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkmark: UIImageView!
    
    var representedAssetIdentifier: String!
    var isCheckmarked: Bool = false
    
    private func flipCheckmark() {
        isCheckmarked = !isCheckmarked
    }
    
    func selected() {
        flipCheckmark()
        setNeedsDisplay()
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            if let isCheckmarked = self?.isCheckmarked {
                self?.checkmark.alpha = isCheckmarked ? 1 : 0
            }
        }
    }
}

//
//  UIImage+Collage.swift
//  ToDoDemoStarter
//
//  Created by QDSG on 2019/3/6.
//  Copyright © 2019 SwifterTT. All rights reserved.
//

import UIKit

extension UIImage {
    /// 适配图片
    private func fixPictureSize(newSize: CGSize) -> CGRect {
        let ratio = max(newSize.width / size.width, newSize.height / size.height)
        
        let width = size.width * ratio
        let height = size.height * ratio
        let scaledRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        return scaledRect
    }
    
    /// 缩放
    func scale(to newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }
        
        let scaleRect = fixPictureSize(newSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(scaleRect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: scaleRect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// 合成用户选中的图片
    static func collage(images: [UIImage], in size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let memoSize = CGSize(width: round(size.width / CGFloat(columns)),
                              height: round(size.height / CGFloat(rows)))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        for (index, image) in images.enumerated() {
            let drawAtX = CGFloat(index % columns) * memoSize.width
            let drawAtY = CGFloat(index / columns) * memoSize.height
            
            image.scale(to: memoSize).draw(at: CGPoint(x: drawAtX, y: drawAtY))
        }
        
        let memoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memoImage ?? UIImage()
    }
    
    static func isEqual(lhs: UIImage, rhs: UIImage) -> Bool {
        guard let data1 = lhs.pngData(), let data2 = rhs.pngData() else { return false }
        
        return data1 == data2
    }
}

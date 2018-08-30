//
//  NumberPageControlPlugin.swift
//  JXPhotoBrowser
//
//  Created by JiongXing on 2018/5/13.
//

import Foundation
import JXPhotoBrowser
import SDWebImage

var lookedPhotoMap: [String: [Int]] = [String: [Int]]()
var actionLogPhotoMap: [String: [Int]] = [String: [Int]]()
class CustomChangeBrowerPlugin: PhotoBrowserPlugin {
    let card: CardResponse
    init(card: CardResponse) {
        self.card = card
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        var lookedIndexs = lookedPhotoMap[card.cardId] ?? [Int]()
        if !lookedIndexs.contains(index) { lookedIndexs.append(index) }
        lookedPhotoMap[card.cardId] = lookedIndexs
        SDImageCache.shared.clearMemory()
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidDisappear view: UIView) {
        SDImageCache.shared.clearMemory()
        if let total = photoBrowser.photoBrowserDelegate?.numberOfPhotos(in: photoBrowser) {
            if actionLogPhotoMap[card.cardId] != nil { return }
            let lookedIndexs = lookedPhotoMap[card.cardId] ?? [Int]()
            if total == lookedIndexs.count {
                CardAction.clickAll.actionLog(card: card) { (isSuccess) in
                    if isSuccess {
                        lookedPhotoMap[self.card.cardId] = nil
                        actionLogPhotoMap[self.card.cardId] = lookedIndexs
                    }
                }
            }
        }
    }
}

class CustomNumberPageControlPlugin: PhotoBrowserPlugin {
    /// 字体
    var font = UIFont.boldSystemFont(ofSize: 20)
    
    /// 字颜色
    var textColor = UIColor.white
    
    /// 中心点距离底部坐标
    var centerBottomY: CGFloat = 28
    
    /// 数字指示
    lazy var numberLabel: UILabel = {
        let view = UILabel()
        view.font = font
        view.textColor = textColor
        return view
    }()
    
    /// 总页码
    var totalPages = 0
    
    /// 当前页码
    var currentPage = 0
    
    init() {}
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, numberOfPhotos count: Int) {
        totalPages = count
        layout()
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        currentPage = index
        layout()
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidAppear view: UIView, animated: Bool) {
        // 页面出来后，再显示页码指示器
        // 多于一张图才显示
        if totalPages > 1 {
            view.addSubview(numberLabel)
        }
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidLayoutSubviews view: UIView) {
        layout()
        numberLabel.isHidden = totalPages <= 1
    }
    
    private func layout() {
        numberLabel.text = "\(currentPage + 1) / \(totalPages)"
        numberLabel.sizeToFit()
        guard let superView = numberLabel.superview else { return }
        var offsetY: CGFloat = 0
        if #available(iOS 11.0, *) {
            offsetY = superView.safeAreaInsets.bottom
        }
        numberLabel.center = CGPoint(x: superView.bounds.midX,
                                     y: superView.bounds.maxY - (centerBottomY + offsetY))
    }
}

//
//  CardImageLayout.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SDWebImage

extension ContentCardCollectionViewCell {
    func layout(urls: [URL]?) {
        imageViews.forEach { view in
            view.alpha = 0
            view.sd_cancelCurrentImageLoad()
        }
        imageIcons.forEach { (view) in
            view.isHidden = true
        }
        imageViewContainers.forEach { view in
            view.isHidden = true
        }
        guard let urls = urls, urls.isNotEmpty else {
            zero()
            return
        }
  
        switch urls.count {
        case 4, 5:
            newFour(urls: Array<URL>(urls[0...3]))
        case 6,7,8:
            newSix(urls: Array<URL>(urls[0...5]))
        case 9:
            newNine(urls: urls)
        case 1:
            one(urls: urls)
        case 2:
            two(urls: urls)
        case 3:
            threeOrFour(urls: urls)
        default:
            break
        }
    }
    
    func newFour(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let imageWidth = (width - spacing) / 2
        let imageHeight = imageWidth
        let size = CGSize(width: imageWidth, height: imageHeight)
        titleLabel.layoutIfNeeded()
        let contentSumHeight = cardCellHeight - 110 -  titleLabel.frame.height
        let contentHeight = viewModel!.contentHeight
        let contentMaxHeight = contentSumHeight - (imageHeight * 2 + spacing)
        contentLabelHeight?.constant = min(contentHeight, contentMaxHeight)
        var viewIndex = 0
        customContent.layoutIfNeeded()
        y = contentImageView.bounds.height - (imageHeight * 2 + spacing)
        urls.forEach { (url) in
            let container = imageViewContainers[viewIndex]
            
            container.isHidden = false
            container.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            setImage(url: url, index: viewIndex)
            x += container.bounds.width + spacing
            if x + container.bounds.width > width {
                x = 0
                y += container.bounds.height + spacing
            }
            viewIndex += 1
        }
    }
    
    func newSix(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let imageWidth = (width - spacing * 2) / 3
        let imageHeight = imageWidth
        let size = CGSize(width: imageWidth, height: imageHeight)
        titleLabel.layoutIfNeeded()
        let contentSumHeight = cardCellHeight - 110 -  titleLabel.frame.height
        let contentHeight = viewModel!.contentHeight
        let contentMaxHeight = contentSumHeight - (imageHeight * 2 + spacing)
        contentLabelHeight?.constant = min(contentHeight, contentMaxHeight)
        var viewIndex = 0
        customContent.layoutIfNeeded()
        y = contentImageView.bounds.height - (imageHeight * 2 + spacing)
        urls.forEach { (url) in
            let container = imageViewContainers[viewIndex]
            container.isHidden = false
            container.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            setImage(url: url, index: viewIndex)
            x += container.bounds.width + spacing
            if x + container.bounds.width > width {
                x = 0
                y += container.bounds.height + spacing
            }
            viewIndex += 1
        }
    }
    
    func newNine(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let imageWidth = (width - spacing * 2) / 3
        let imageHeight = imageWidth
        let size = CGSize(width: imageWidth, height: imageHeight)
        titleLabel.layoutIfNeeded()
        let contentSumHeight = cardCellHeight - 110 -  titleLabel.frame.height
        let contentHeight = viewModel!.contentHeight
        let contentMaxHeight = contentSumHeight - (imageHeight * 3 + 2 * spacing)
        contentLabelHeight?.constant = min(contentHeight, contentMaxHeight)
        var viewIndex = 0
        customContent.layoutIfNeeded()
        y = contentImageView.bounds.height - (imageHeight * 3 + 2 * spacing)
        urls.forEach { (url) in
            let container = imageViewContainers[viewIndex]
            container.isHidden = false
            container.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            setImage(url: url, index: viewIndex)
            x += container.bounds.width + spacing
            if x + container.bounds.width > width {
                x = 0
                y += container.bounds.height + spacing
            }
            viewIndex += 1
        }
    }
    
    func zero() {
        titleLabel.layoutIfNeeded()
        let contentHeight = viewModel!.contentHeight
        let contentMaxHeight = cardCellHeight - 110 -  titleLabel.frame.height
        contentLabelHeight?.constant = min(contentHeight, contentMaxHeight)
        
    }
    
    func one(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        let width = contentImageView.bounds.width - margin * 2
        let container = imageViewContainers[0]
        container.isHidden = false
        let containerMinSize = CGSize(width: (width - 2 * spacing) / 3 , height: (width - 2 * spacing) / 3)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 -  titleLabel.frame.height - containerMinSize.height
        let contentHeight = viewModel!.contentHeight
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            let y = contentImageView.bounds.height - containerMinSize.height
            container.frame = CGRect(origin: CGPoint(x: 0, y: y), size: containerMinSize)
        } else {
            contentLabelHeight?.constant = contentHeight
            let scaleWidth = containerMinSize.width + (contentMaxHeight - contentHeight) > width
                ?  width : containerMinSize.width + (contentMaxHeight - contentHeight)
            let containerSize =  CGSize(width: scaleWidth, height: scaleWidth)
            customContent.layoutIfNeeded()
            let y = contentImageView.bounds.height - containerSize.height
            container.frame = CGRect(origin: CGPoint(x: 0, y: y),size: containerSize)
        }
        setImage(url: urls[0], index: 0, isAutoAnimating: true)
    }
    
    func two(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let containerMinSize = CGSize(width: (width - 2 * spacing) / 3 , height: (width - 2 * spacing) / 3)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 -  titleLabel.frame.height - containerMinSize.height
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - containerMinSize.height
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                setImage(url: url, index: viewIndex)
                x += container.bounds.width + spacing
                viewIndex += 1
            }
        } else {
            let containerMaxHeight = (width - spacing * 1) / 2
            let containerSumHeight = containerMaxHeight
            let textSpacing = cardCellHeight - contentHeight - 110 - titleLabel.frame.height - containerSumHeight
            if textSpacing > 40 && urls.count == viewModel!.imageURLList!.count {
                let newUrls = Array<URL>(urls[0..<urls.count - 1])
                one(urls: newUrls)
            } else {
                contentLabelHeight?.constant = contentHeight
                customContent.layoutIfNeeded()
                let scaleWidth = containerMinSize.width + (contentMaxHeight - contentHeight) > containerMaxHeight
                    ?  containerMaxHeight : containerMinSize.width + (contentMaxHeight - contentHeight)
                let containerSize =  CGSize(width: scaleWidth, height: scaleWidth)
                y = contentImageView.bounds.height - containerSize.height
                urls.forEach { (url) in
                    let container = imageViewContainers[viewIndex]
                    container.isHidden = false
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),size: containerSize)
                    setImage(url: url, index: viewIndex)
                    x += container.bounds.width + spacing
                    viewIndex += 1
                }
            }
        }
    }
    
    func threeOrFour(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let count = CGFloat(urls.count)
        let bottomWidth = (width - spacing * (count - 2)) / (count - 1)
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: width , height: bottomHeight)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 2 * bottomHeight - spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - 2 * bottomHeight - spacing
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex == 0 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    y += container.bounds.height + spacing
                } else {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth,
                                                          height: bottomHeight))
                    x += container.bounds.width + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            contentLabelHeight?.constant = contentHeight
            customContent.layoutIfNeeded()
            let scaleHeight = containerMinSize.height + (contentMaxHeight - contentHeight) > width
                ?  width : containerMinSize.height + (contentMaxHeight - contentHeight)
            let containerSize =  CGSize(width: width, height: scaleHeight)
            y = contentImageView.bounds.height - containerSize.height - bottomHeight - spacing
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex == 0 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerSize)
                    y += container.bounds.height + spacing
                } else {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth,
                                                          height: bottomHeight))
                    x += container.bounds.width + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        }
    }
    
    func five(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let bottomWidth = (width - spacing * 2) / 3
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: (width - spacing) / 2, height: bottomHeight)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 2 * bottomHeight - spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - 2 * bottomHeight - spacing
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex == 0 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    x += container.bounds.width + spacing
                } else if viewIndex == 1 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    y += container.bounds.height + spacing
                } else {
                    if viewIndex == 2 { x = 0 }
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth, height: bottomHeight))
                    x += container.bounds.width + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            let containerMaxHeight = (width - spacing) / 2
            let containerSumHeight = containerMaxHeight + bottomHeight + spacing
            let textSpacing = cardCellHeight - 110 - titleLabel.frame.height - contentHeight - containerSumHeight
            if textSpacing > 40 && urls.count == viewModel!.imageURLList!.count {
                let newUrls = Array<URL>(urls[0..<urls.count - 1])
                threeOrFour(urls: newUrls)
            } else {
                contentLabelHeight?.constant = contentHeight
                customContent.layoutIfNeeded()
                let scaleHeight = containerMinSize.height + (contentMaxHeight - contentHeight) > containerMaxHeight
                    ?  containerMaxHeight : containerMinSize.height + (contentMaxHeight - contentHeight)
                let containerSize = CGSize(width: (width - spacing) / 2, height: scaleHeight)
                y = contentImageView.bounds.height - containerSize.height - bottomHeight - spacing
                urls.forEach { (url) in
                    let container = imageViewContainers[viewIndex]
                    container.isHidden = false
                    if viewIndex <= 1 {
                        container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerSize)
                        x += container.bounds.width + spacing
                        if x + container.bounds.width > width {
                            x = 0
                            y += container.bounds.height + spacing
                        }
                    } else {
                        container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                                 size: CGSize(width: bottomWidth, height: bottomHeight))
                        x += container.bounds.width + spacing
                    }
                    setImage(url: url, index: viewIndex)
                    viewIndex += 1
                }
            }
        }
        
    }
    
    func six(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let bottomWidth = (width - spacing * 2) / 3
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: (width - 2 * spacing) / 3 , height: (width - spacing * 2) / 3)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 2 * bottomHeight - spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - 2 * bottomHeight - spacing
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                x += container.bounds.width + spacing
                if x + container.bounds.width > width {
                    x = 0
                    y += container.bounds.height + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            let containerMaxHeight = bottomWidth
            let containerSumHeight = containerMaxHeight + bottomHeight + spacing
            let textSpacing = cardCellHeight - 110 - titleLabel.frame.height - contentHeight - containerSumHeight
            if textSpacing > 40 && urls.count == viewModel!.imageURLList!.count {
                let newUrls = Array<URL>(urls[0..<urls.count - 1])
                five(urls: newUrls)
            } else {
                contentLabelHeight?.constant = contentHeight
                customContent.layoutIfNeeded()
                y = contentImageView.bounds.height - 2 * bottomHeight - spacing
                urls.forEach { (url) in
                    let container = imageViewContainers[viewIndex]
                    container.isHidden = false
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    x += container.bounds.width + spacing
                    if x + container.bounds.width > width {
                        x = 0
                        y += container.bounds.height + spacing
                    }
                    setImage(url: url, index: viewIndex)
                    viewIndex += 1
                }
            }
        }
    }
    
    func seven(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let bottomWidth = (width - spacing * 2) / 3
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: width , height: bottomHeight)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 3 * bottomHeight - 2 * spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - bottomHeight * 3 - spacing * 2
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex == 0 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    y += container.bounds.height + spacing
                } else {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth,
                                                          height: bottomHeight))
                    x += container.bounds.height + spacing
                    if x + container.bounds.height > width {
                        x = 0
                        y += container.bounds.height + spacing
                    }
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            contentLabelHeight?.constant = contentHeight
            customContent.layoutIfNeeded()
            let scaleHeight = containerMinSize.height + (contentMaxHeight - contentHeight) > width
                ?  width : containerMinSize.height + (contentMaxHeight - contentHeight)
            let containerSize =  CGSize(width: width, height: scaleHeight)
            y = contentImageView.bounds.height - bottomHeight * 2 - containerSize.height - spacing * 2
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex == 0 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerSize)
                    y += container.bounds.height + spacing
                } else {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth, height: bottomHeight))
                    x += container.bounds.height + spacing
                    if x + container.bounds.height > width {
                        x = 0
                        y += container.bounds.height + spacing
                    }
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        }
    }
    
    func eight(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let bottomWidth = (width - spacing * 2) / 3
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: (width - spacing) / 2 , height: bottomHeight)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 3 * bottomHeight - 2 * spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - bottomHeight * 3 - spacing * 2
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                if viewIndex <= 1 {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                    x += container.bounds.width + spacing
                    if x + container.bounds.width > width {
                        x = 0
                        y += container.bounds.height + spacing
                    }
                } else {
                    container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                             size: CGSize(width: bottomWidth, height: bottomHeight))
                    x += container.bounds.height + spacing
                    if x + container.bounds.height > width {
                        x = 0
                        y += container.bounds.height + spacing
                    }
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            let containerMaxHeight = (width - spacing) / 2
            let containerSumHeight = containerMaxHeight + bottomWidth * 2 + spacing * 2
            let textSpacing = cardCellHeight - 110 - titleLabel.frame.height - contentHeight - containerSumHeight
            if textSpacing > 40 && urls.count == viewModel!.imageURLList!.count  {
                let newUrls = Array<URL>(urls[0..<urls.count - 1])
                seven(urls: newUrls)
            } else {
                contentLabelHeight?.constant = contentHeight
                customContent.layoutIfNeeded()
                let scaleHeight = containerMinSize.height + (contentMaxHeight - contentHeight) > containerMaxHeight
                    ?  containerMaxHeight : containerMinSize.height + (contentMaxHeight - contentHeight)
                let containerSize =  CGSize(width: (width - spacing) / 2, height: scaleHeight)
                y = contentImageView.bounds.height - containerSize.height - bottomHeight * 2 - spacing * 2
                urls.forEach { (url) in
                    let container = imageViewContainers[viewIndex]
                    container.isHidden = false
                    if viewIndex <= 1 {
                        container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerSize)
                        x += container.bounds.width + spacing
                        if x + container.bounds.width > width {
                            x = 0
                            y += container.bounds.height + spacing
                        }
                    } else {
                        container.frame = CGRect(origin: CGPoint(x: x, y: y),
                                                 size: CGSize(width: bottomWidth, height: bottomHeight))
                        x += container.bounds.height + spacing
                        if x + container.bounds.height > width {
                            x = 0
                            y += container.bounds.height + spacing
                        }
                    }
                    setImage(url: url, index: viewIndex)
                    viewIndex += 1
                }
            }
        }
    }
    
    func nine(urls: [URL]) {
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        var x = margin
        var y = margin
        let width = contentImageView.bounds.width - margin * 2
        let bottomWidth = (width - spacing * 2) / 3
        let bottomHeight = bottomWidth
        let containerMinSize = CGSize(width: bottomWidth , height: bottomHeight)
        titleLabel.layoutIfNeeded()
        let contentMaxHeight = cardCellHeight - 110 - titleLabel.frame.height - 3 * bottomHeight - 2 * spacing
        let contentHeight = viewModel!.contentHeight
        var viewIndex = 0
        if contentHeight > contentMaxHeight {
            contentLabelHeight?.constant = contentMaxHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - bottomHeight * 3 - spacing * 2
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                x += container.bounds.width + spacing
                if x + container.bounds.width > width {
                    x = 0
                    y += container.bounds.height + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        } else {
            contentLabelHeight?.constant = contentHeight
            customContent.layoutIfNeeded()
            y = contentImageView.bounds.height - bottomHeight * 3 - spacing * 2
            urls.forEach { (url) in
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                container.frame = CGRect(origin: CGPoint(x: x, y: y), size: containerMinSize)
                x += container.bounds.width + spacing
                if x + container.bounds.width > width {
                    x = 0
                    y += container.bounds.height + spacing
                }
                setImage(url: url, index: viewIndex)
                viewIndex += 1
            }
        }
    }

    func setImage(url : URL?, index: Int, isAutoAnimating: Bool = false) {
        let imageView = imageViews[index]
        let imageIcon = imageIcons[index]
        customContent.layoutIfNeeded()
        url?.imageInfoSize { (info, isSuccess) in
            guard isSuccess, let info = info else { return }
            if info.format == "gif" {
                imageIcon.isHidden = isAutoAnimating
                imageIcon.setTitle("GIF", for: .normal)
            } else {
                if CGFloat(info.height) / CGFloat(info.width) > 1.95 {
                    imageIcon.isHidden = false
                    imageIcon.setTitle("长图", for: .normal)
                } else {
                    imageIcon.isHidden = true
                }
            }
        }
        guard let url = url?.imageView2(size: imageView.bounds.size) else { return }

        SDWebImageManager.shared.loadImage(
               with: url,
               options: [.decodeFirstFrameOnly],
               progress: nil) { (image, data, _, _, _, _) in
                guard let image = image else { return }
                imageView.image = nil
                if isAutoAnimating {
                    imageView.image = image
                } else {
                    if let images = image.images {
                        imageView.image = images[0]
                    } else {
                        imageView.image = image
                    }
                }
                UIView.animate(withDuration: 0.25, animations: {
                    imageView.alpha = 1
                })
        }
    }
}

// MARK: - Image format
private struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
    static var JPEG_IF: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47, 0x49, 0x46]
}

enum ImageFormat {
    case unknown, PNG, JPEG, GIF
}

extension Data {
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (self as NSData).getBytes(&buffer, length: 8)
        if buffer == ImageHeaderData.PNG {
            return .PNG
        } else if buffer[0] == ImageHeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageHeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageHeaderData.JPEG_IF[0]
        {
            return .JPEG
        } else if buffer[0] == ImageHeaderData.GIF[0] &&
            buffer[1] == ImageHeaderData.GIF[1] &&
            buffer[2] == ImageHeaderData.GIF[2]
        {
            return .GIF
        }
        
        return .unknown
    }
}

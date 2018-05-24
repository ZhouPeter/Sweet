//
//  NewsCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContentCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    typealias ViewModelType = ContentCardViewModel
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private var imageViews = [UIImageView]()
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 15)
        customContent.addSubview(contentImageView)
        contentImageView.align(.left, to: customContent)
        contentImageView.align(.right, to: customContent)
        contentImageView.align(.bottom, to: customContent)
        contentImageView.equal(.height, to: contentImageView)
        contentImageView.heightAnchor.constraint(
                equalTo: contentImageView.widthAnchor,
                multiplier: 10.0 / 9.0).isActive = true
        contentImageView.setViewRounded(cornerRadius: 10, corners: [.bottomLeft, .bottomRight])
        setImageViews()

    }
    
    private func setImageViews() {
        var orginX: CGFloat = 0
        var orginY: CGFloat = 0
        let sumWidth: CGFloat = UIScreen.mainWidth() - 20
        let sumHeight: CGFloat = sumWidth * 10 / 9
        for index in 0..<9 {
            let imageView = UIImageView()
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            if orginX + sumWidth / 3 > sumWidth {
                orginX = 0
                orginY += sumHeight / 3
            }
            let rect = CGRect(origin: CGPoint(x: orginX, y: orginY),
                              size: CGSize(width: sumWidth / 3, height: sumHeight / 3))
            imageView.frame = rect
            orginX += sumWidth / 3
//            imageView.kf.setImage(with: URL(string: "http://pic.58pic.com/58pic/14/25/01/74w58PICP5D_1024.jpg"))
            imageView.backgroundColor = UIColor.black
            imageViews.append(imageView)
            contentImageView.addSubview(imageView)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentCardViewModel) {
        contentLabel.text = viewModel.contentString
        setContentImages(images: viewModel.contentImages)
        
    }
    
    private func setContentImages(images: [ContentImageModel]?) {
        guard let images = images else {
            imageViews.forEach { $0.isHidden = true }
            return
        }
        var orginX: CGFloat = 0
        var orginY: CGFloat = 0
        let sumWidth: CGFloat = UIScreen.mainWidth() - 20
        for (offset, imageView) in imageViews.enumerated() {
            if offset < images.count {
                imageView.isHidden = false
                contentImageView.addSubview(imageView)
                let imageSize = images[offset].size
                if orginX + imageSize.width > sumWidth {
                    orginX = 0
                    orginY += images[offset - 1].size.height
                }
                logger.debug(orginX)
                logger.debug(orginY)
                logger.debug(imageSize.width)
                logger.debug(imageSize.height)
                let rect = CGRect(origin: CGPoint(x: orginX, y: orginY),
                                  size: CGSize(width: imageSize.width, height: imageSize.height))
                imageView.frame = rect
                imageView.kf.setImage(with: images[offset].imageURL)
                orginX += imageSize.width
            } else {
                imageView.isHidden = true
                imageView.removeFromSuperview()
            }
        }
    }
}

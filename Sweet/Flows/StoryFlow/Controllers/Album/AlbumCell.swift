//
//  AlbumCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func configureCell(_ image: UIImage, duration: TimeInterval? = nil) {
        let animated = imageView.alpha < 1
        imageView.image = image
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.imageView.alpha = 1
            }, completion: nil)
        }
        if let duration = duration {
            let minutes = Int(floor(duration / 60))
            let seconds = Int(duration - Double(minutes * 60))
            label.text = String(format: "%2d:%02d", minutes, seconds)
        } else {
            label.text = nil
        }
    }
    
    private func setup() {
        backgroundColor = .white
        contentView.addSubview(imageView)
        imageView.fill(in: contentView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(label)
        label.align(.left, to: contentView, inset: 5)
        label.align(.bottom)
        label.align(.right, to: contentView, inset: 5)
        imageView.alpha = 0
    }
}

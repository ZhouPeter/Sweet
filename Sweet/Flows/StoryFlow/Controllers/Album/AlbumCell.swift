//
//  AlbumCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    override var isSelected: Bool {
        didSet {
            checkImageView.image = isSelected ? #imageLiteral(resourceName: "Checked") : #imageLiteral(resourceName: "UnChecked")
        }
    }
    
    private var imageView = UIImageView()
    private var checkImageView = UIImageView(image: #imageLiteral(resourceName: "UnChecked"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func configureCell(_ image: UIImage) {
        let animated = imageView.alpha < 1
        imageView.image = image
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.imageView.alpha = 1
                self.checkImageView.alpha = 1
            }, completion: nil)
        }
    }
    
    private func setup() {
        backgroundColor = .white
        contentView.addSubview(imageView)
        imageView.fill(in: contentView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(checkImageView)
        checkImageView.constrain(width: 20, height: 20)
        checkImageView.align(.top, to: contentView, inset: 5)
        checkImageView.align(.right, to: contentView, inset: 5)
        checkImageView.alpha = 0
        imageView.alpha = 0
    }
}

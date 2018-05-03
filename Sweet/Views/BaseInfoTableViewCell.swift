//
//  ProfileBaseInfoTableViewCell.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/3/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Kingfisher

protocol BaseInfoTableViewCellDelegate: NSObjectProtocol {
    
}

class BaseInfoTableViewCell: UITableViewCell, CellReusable, CellUpdatable {

    typealias ViewModelType = BaseInfoCellViewModel
    weak var delegate: BaseInfoTableViewCellDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var collegeInfoLabel: UILabel!
    @IBOutlet weak var abstractInfoLabel: UILabel!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var senderButton: UIButton!
    private var viewModel: ViewModelType?
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        senderButton.isHidden = true
        subscribeButton.isHidden = true
        avatarImageView.setViewRounded()
        senderButton.setViewRounded(borderWidth: 1, borderColor: UIColor.xpBlue())
        subscribeButton.setViewRounded(borderWidth: 1, borderColor: .black)
        subscribeButton.addTarget(self, action: #selector(subscribeAction), for: .touchUpInside)
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.size.height -= 10
            super.frame = newFrame
        }
    }
    
    func updateWith(_ viewModel: BaseInfoCellViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.nameString
        avatarImageView.kf.setImage(with: viewModel.avatarImageURL)
        collegeInfoLabel.attributedText = getTextAttributedString(text: viewModel.networkString)
        abstractInfoLabel.attributedText = getTextAttributedString(text: viewModel.signatureString)
        likeCountButton.setTitle(viewModel.likeCountString, for: .normal)
        subscribeButton.setTitle(viewModel.subscribeButtonString, for: .normal)
    }
    
    private func getTextAttributedString(text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 9
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    @objc private func subscribeAction() {
        viewModel?.subscribeAction?()
    }
    
}
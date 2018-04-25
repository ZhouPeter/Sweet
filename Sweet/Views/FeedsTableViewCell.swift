//
//  FeedsTableViewCell.swift
//  XPro
//
//  Created by Mario Z. on 2018/3/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class FeedsTableViewCell: UITableViewCell, CellUpdatable, CellReusable {
    typealias ViewModelType = FeedsCellViewModel
    
    var viewModel: FeedsCellViewModel?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topSubtitleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 30
        bottomLabel.numberOfLines = 0
    }

    func updateWith(_ viewModel: FeedsCellViewModel) {
        self.viewModel = viewModel
        avatarImageView.kf.setImage(with: viewModel.avatarURL, placeholder: #imageLiteral(resourceName: "Avatar"))
        topLabel.text = viewModel.title
        topSubtitleLabel.text = viewModel.subtitle
        bottomLabel.text = viewModel.content
        bottomLabel.font = viewModel.bottomLabelFont
        actionButton.setImage(viewModel.actionImage, for: .normal)
        actionButton.setImage(viewModel.actionImageSelected, for: .highlighted)
        actionButton.setImage(viewModel.actionImageSelected, for: .selected)
    }
    
    @IBAction func didPressActionButton(_ sender: Any) {
        viewModel?.doAction?()
    }
}

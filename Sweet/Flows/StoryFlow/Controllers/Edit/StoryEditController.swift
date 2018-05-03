//
//  StoryEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryEditController: BaseViewController, StoryEditView {
    var onCancelled: (() -> Void)?
    var onFinished: ((URL) -> Void)?
    
    private let fileURL: URL
    private let isPhoto: Bool
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryBack"), for: .normal)
        button.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryEdit"), for: .normal)
        button.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryConfirm"), for: .normal)
        button.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var previewController = StoryFilterPreviewController(fileURL: self.fileURL, isPhoto: self.isPhoto)
    
    init(fileURL: URL, isPhoto: Bool) {
        self.fileURL = fileURL
        self.isPhoto = isPhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPreview()
        setupBottomButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewController.stopPreview()
    }
    
    // MARK: - Private
    
    private func setupBottomButtons() {
        view.addSubview(backButton)
        backButton.constrain(width: 40, height: 40)
        backButton.align(.left, to: view, inset: 10)
        backButton.align(.bottom, to: view, inset: 10)
        view.addSubview(editButton)
        editButton.constrain(width: 40, height: 40)
        editButton.centerX(to: view)
        editButton.centerY(to: backButton)
        view.addSubview(finishButton)
        finishButton.constrain(width: 40, height: 40)
        finishButton.centerY(to: editButton)
        finishButton.align(.right, to: view, inset: 10)
    }
    
    private func setupPreview() {
        addChildViewController(previewController)
        previewController.didMove(toParentViewController: self)
        view.addSubview(previewController.view)
        previewController.view.fill(in: view)
    }
    
    // MARK: - Actions
    
    @objc private func didPressBackButton() {
        onCancelled?()
    }
    
    @objc private func didPressEditButton() {
        
    }
    
    @objc private func didPressFinishButton() {
        
    }
}

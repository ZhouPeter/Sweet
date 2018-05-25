//
//  AlbumController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Photos

protocol AlbumView: BaseView {
    
}

final class AlbumController: UIViewController, AlbumView {
    var onCancelled: (() -> Void)?
    
    private var assets = [PHAsset]()
    
    private lazy var itemSize: CGSize = {
        let length = self.view.bounds.width * 0.25
        return CGSize(width: length, height: length)
    } ()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = self.itemSize
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.register(AlbumCell.self, forCellWithReuseIdentifier: "Cell")
        view.backgroundColor = .clear
        return view
    } ()
    
    private lazy var rightBarButton =
        UIBarButtonItem(title: "继续", style: .plain, target: self, action: #selector(didPressRightBarButton))
    
    private var selectedIndexPath: IndexPath? {
        didSet {
            rightBarButton.isEnabled = selectedIndexPath != nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "所有照片"
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.isEnabled = false
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        checkAuthorized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar
    }
    
    // MARK: - Private
    
    private func checkAuthorized() {
        if TLAuthorizedManager.checkAuthorization(with: .album) {
            fetchPhotos()
        } else {
            TLAuthorizedManager.requestAuthorization(with: .album) { [weak self] (_, success) in
                guard let `self` = self else { return }
                if success {
                   self.fetchPhotos()
                } else {
                    logger.debug("Unauthorized")
                }
            }
        }
    }
    
    private func fetchPhotos(_ completion: (() -> Void)? = nil) {
        AssetManager.fetch { [weak self] assets in
            guard let `self` = self else { return }
            self.assets.removeAll()
            self.assets.append(contentsOf: assets)
            self.collectionView.reloadData()
            completion?()
        }
    }

    @objc private func didPressRightBarButton() {
        
    }
}

extension AlbumController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? AlbumCell
        else {
            fatalError()
        }
        let asset = assets[indexPath.row]
        AssetManager.resolveAsset(asset, size: itemSize) { image in
            if let image = image {
                cell.configureCell(image)
            }
        }
        return cell
    }
}

extension AlbumController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}

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
    var onCancelled: (() -> Void)? { get set }
    var onFinished: ((URL, Bool) -> Void)? { get set }
}

final class AlbumController: UIViewController, AlbumView {
    var onFinished: ((URL, Bool) -> Void)?
    var onCancelled: (() -> Void)?
    
    private var fetchResult: PHFetchResult<PHAsset>?
    
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
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            onCancelled?()
        }
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
    
    private func fetchPhotos() {
        fetchResult = AssetManager.fetch()
        collectionView.reloadData()
    }

    @objc private func didPressRightBarButton() {
//        guard let indexPath = selectedIndexPath, let result = fetchResult else { return }
//        AssetManager.resolveAsset(result[indexPath.row]) { [weak self] (image) in
//            guard let image = image else { return }
//            self?.onFinished?(image)
//        }
    }
}

extension AlbumController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let result = fetchResult,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? AlbumCell
        else {
            fatalError()
        }
        let asset = result[indexPath.row]
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
        guard let result = fetchResult else { return }
        let isPhoto = true
        AssetManager.resolveAsset(result[indexPath.row]) { [weak self] (image) in
            guard let url = image?.writeToCache(withAlpha: false) else { return }
            self?.onFinished?(url, isPhoto)
        }
    }
}

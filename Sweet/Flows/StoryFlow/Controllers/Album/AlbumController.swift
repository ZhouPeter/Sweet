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
    
    private var isTrimmed = false
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
    
    deinit {
        logger.debug()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "所有照片"
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
                var duration: TimeInterval?
                if asset.mediaType == .video {
                    duration = asset.duration
                }
                cell.configureCell(image, duration: duration)
            }
        }
        return cell
    }
}

extension AlbumController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let result = fetchResult else { return }
        let asset = result[indexPath.row]
        if asset.mediaType == .image {
            AssetManager.resolveAsset(asset) { [weak self] (image) in
                guard let url = image?.writeToCache(withAlpha: false) else { return }
                self?.onFinished?(url, true)
            }
            return
        }
        if asset.mediaType == .video {
            AssetManager.resolveAVAsset(asset) { [weak self] (url) in
                guard let `self` = self, let url = url else { return }
                logger.debug(url)
                let controller = UIVideoEditorController()
                controller.videoPath = url.path
                controller.videoMaximumDuration = 10
                controller.delegate = self
                controller.videoQuality = .typeMedium
                self.isTrimmed = false
                self.present(controller, animated: true, completion: nil)
            }
            return
        }
    }
}

extension AlbumController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        logger.debug()
        editor.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        logger.error(error)
        editor.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        logger.debug(editedVideoPath)
        guard isTrimmed == false else { return }
        isTrimmed = true
        editor.dismiss(animated: false, completion: nil)
        let editedVideoURL = URL(string: editedVideoPath)!
        do {
            let target = URL.videoCacheURL(withName: editedVideoURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: target.path) {
                try? FileManager.default.removeItem(atPath: target.path)
            }
            try FileManager.default.copyItem(atPath: editedVideoURL.path, toPath: target.path)
            self.onFinished?(target, false)
        } catch {
            logger.error(error)
        }
    }
}

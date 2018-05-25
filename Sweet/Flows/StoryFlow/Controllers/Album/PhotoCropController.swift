//
//  PhotoCropController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol PhotoCropView: BaseView {
    var onFinished: ((URL) -> Void)? { get set }
}

final class PhotoCropController: UIViewController, PhotoCropView {
    var onFinished: ((URL) -> Void)?
    private var photo: UIImage
    private var photoTransform = Transform()
    private lazy var photoView: UIImageView = {
        let view = UIImageView(image: photo)
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        return view
    } ()
    
    init(with photo: UIImage) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选中照片"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "继续", style: .plain, target: self, action: #selector(didPressRightBarButton))
        view.backgroundColor = .white
        view.addSubview(photoView)
        photoView.fill(in: view)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        pinch.delegate = self
        view.addGestureRecognizer(pinch)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotate.delegate = self
        view.addGestureRecognizer(rotate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar
    }
    
    // MARK: - Private
    
    @objc private func didPressRightBarButton() {
        guard let image = view.screenshot() else { return }
        finish(with: image)
    }
    
    private func finish(with image: UIImage) {
        guard let url = image.writeToCache() else { return }
        onFinished?(url)
    }
    
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        photoTransform.translation.x += translation.x
        photoTransform.translation.y += translation.y
        gesture.setTranslation(.zero, in: view)
        doTransform()
    }
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        photoTransform.rotation += gesture.rotation
        gesture.rotation = 0
        doTransform()
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        photoTransform.scale *= gesture.scale
        gesture.scale = 1
        doTransform()
    }
    
    private func doTransform() {
        let transform = photoTransform.makeCGAffineTransform()
        photoView.transform = transform
    }
}

extension PhotoCropController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

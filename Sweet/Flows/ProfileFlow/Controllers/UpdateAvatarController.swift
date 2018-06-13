//
//  UpdateAvatarController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Photos
import SwiftyUserDefaults
class UpdateAvatarController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String) -> Void)?
    
    var avatar: String
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: URL(string: avatar)!)
        return imageView
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Menu_white"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Back").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    init(avatar: String) {
        self.avatar = avatar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.title = "修改头像"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        view.addSubview(avatarImageView)
        avatarImageView.constrain(width: UIScreen.mainWidth(), height: UIScreen.mainWidth())
        avatarImageView.centerX(to: view)
        avatarImageView.align(.top, to: view, inset: UIScreen.navBarHeight() + 36)
    }
    @objc private func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func moreAction(_ sender: UIButton) {
        let alertController = UIAlertController()
        let cameraAction = UIAlertAction.makeAlertAction(title: "拍摄", style: .default) { (_) in
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if granted {
                    var sourceType: UIImagePickerControllerSourceType = .camera
                    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                        sourceType = .savedPhotosAlbum
                    }
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.allowsEditing = false
                    imagePickerController.sourceType = sourceType
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            })
        }
        let libraryAction = UIAlertAction.makeAlertAction(title: "从手机相册中选取", style: .default) { (_) in
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    let sourceType: UIImagePickerControllerSourceType = .photoLibrary
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.allowsEditing = false
                    imagePickerController.sourceType = sourceType
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UpdateAvatarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let localURL = URL.avatarCachesURL(withName: UUID().uuidString)
        guard let newImage = image.thumbnail(withSize: CGSize(width: 800, height: 800)) else { return }
        do {
            try UIImageJPEGRepresentation(newImage, 0.7)?.write(to: localURL)
            Upload.uploadFileToQiniu(localURL: localURL, type: .userAvatar) { (response, error) in
                guard let response = response, error == nil else {
                    logger.debug(error ?? "")
                    self.toast(message: "头像上传失败", duration: 2)
                    return
                }
                let url = response.host + response.key
                web.request(
                    .update(updateParameters: ["avatar": url,
                                               "type": UpdateUserType.avatar.rawValue]),
                            completion: { (result) in
                                switch result {
                                case .success:
                                    self.avatarImageView.kf.setImage(with: localURL)
                                    self.saveCompletion?(url)
                                case let .failure(error):
                                    self.toast(message: "修改头像失败", duration: 2)
                                    logger.error(error)
                                }
                })
            }
        } catch {
            logger.debug(error)
            self.toast(message: "头像上传失败", duration: 2)
        }
    }
}

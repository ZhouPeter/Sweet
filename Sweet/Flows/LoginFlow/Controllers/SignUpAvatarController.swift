//
//  AvatarViewController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/1/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Photos
class SignUpAvatarController: BaseViewController, SignUpAvatarView {
    var showSignUpPhone: ((LoginRequestBody) -> Void)?
    var loginRequestBody: LoginRequestBody!
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Camera_icon"), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didPressCameraButton(button:)), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpYellow()
        navigationItem.title = "上传头像"
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        setupUI()
        cameraButton.addTarget(self, action: #selector(didPressCameraButton(button:)), for: .touchUpInside)
        
    }
    
    private func setupUI() {
        view.addSubview(cameraButton)
        cameraButton.center(to: view, offsetY: -50)
        cameraButton.constrain(width: 100, height: 100)
        cameraButton.setViewRounded(borderWidth: 1, borderColor: UIColor.xpDarkGray())
    }

    @objc private func didPressCameraButton(button: UIButton) {
        let alertController = UIAlertController()
        alertController.view.tintColor = .black
        let cameraAction =  UIAlertAction.makeAlertAction(title: "拍摄照片", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if granted {
                    var sourceType: UIImagePickerControllerSourceType = .camera
                    // 跳转到相机
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    } else {
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
        let photoAction = UIAlertAction.makeAlertAction(
                   title: "从手机相册选取",
                   style: .default,
                   handler: {(_ action: UIAlertAction) -> Void in
            // 跳转到相册
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    let sourceType: UIImagePickerControllerSourceType = .photoLibrary
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.allowsEditing = false
                    imagePickerController.sourceType = sourceType
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            })
        })
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension SignUpAvatarController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
                self.cameraButton.setImage(newImage, for: .normal)
                self.loginRequestBody.avatar = response.host + response.key
                self.showSignUpPhone?(self.loginRequestBody)
            }
        } catch {
            logger.debug(error)
            self.toast(message: "头像上传失败", duration: 2)
        }
    }
}

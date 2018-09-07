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
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = "tips：完整的个人资料可以在“主页-设置”中修改"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private lazy var nextButton: ShrinkButton = {
        let button = ShrinkButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("下一步", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = .black
        button.alpha = 0.5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
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
    
    @objc private func nextAction(_ sender: UIButton) {
        self.showSignUpPhone?(self.loginRequestBody)
    }
    
    private func setupUI() {
        view.addSubview(cameraButton)
        cameraButton.center(to: view, offsetY: -50)
        cameraButton.constrain(width: 100, height: 100)
        cameraButton.setViewRounded(borderWidth: 1, borderColor: UIColor.xpDarkGray())
        view.addSubview(nextButton)
        nextButton.constrain(height: 50)
        nextButton.align(.left, inset: 28)
        nextButton.align(.right, inset: 28)
        nextButton.align(.bottom, inset: 120 + UIScreen.safeBottomMargin())
        nextButton.setViewRounded()
        view.addSubview(tipLabel)
        tipLabel.pin(.top, to: nextButton, spacing: 10)
        tipLabel.centerX(to: nextButton)
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
                    self.toast(message: "头像上传失败")
                    return
                }
                self.cameraButton.setImage(newImage, for: .normal)
                self.nextButton.isUserInteractionEnabled = true
                self.nextButton.alpha = 1
                self.loginRequestBody.avatar = response.host + response.key
            }
        } catch {
            logger.debug(error)
            self.toast(message: "头像上传失败")
        }
    }
}

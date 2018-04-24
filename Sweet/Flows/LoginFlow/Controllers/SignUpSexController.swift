//
//  SignUpSexController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpSexController: BaseViewController, SignUpSexView {
    var showSignUpName: ((LoginRequestBody) -> Void)?
    
    var loginRequestBody: LoginRequestBody!
    private var boyImageView: UIImageView!
    private var girlImageView: UIImageView!
    private lazy var boyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        let imageView = UIImageView()
        boyImageView = imageView
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        imageView.constrain(width: 80, height: 80)
        imageView.image = #imageLiteral(resourceName: "Boy_icon")
        stackView.addArrangedSubview(imageView)
        let label = UILabel()
        label.text = "男生"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        stackView.addArrangedSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(boyAction(_:)))
        stackView.addGestureRecognizer(tap)
        return stackView
    }()
    
    private lazy var girlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        let imageView = UIImageView()
        girlImageView = imageView
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        imageView.constrain(width: 80, height: 80)
        imageView.image = #imageLiteral(resourceName: "Girl_icon")
        stackView.addArrangedSubview(imageView)
        let label = UILabel()
        label.text = "女生"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        stackView.addArrangedSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(girlAction(_:)))
        stackView.addGestureRecognizer(tap)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "你的性别"
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        view.backgroundColor = UIColor.xpYellow()
        setSexStackView()
    }
    
    private func setSexStackView() {
        view.addSubview(boyStackView)
        boyStackView.centerY(to: view)
        boyStackView.centerX(to: view, offset: -68)
        boyStackView.constrain(width: 80, height: 130)
        view.addSubview(girlStackView)
        girlStackView.centerY(to: view)
        girlStackView.centerX(to: view, offset: 68)
        girlStackView.constrain(width: 80, height: 130)
    }
    
    @objc private func boyAction(_ sender: UITapGestureRecognizer) {
        boyImageView.backgroundColor = .white
        girlImageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        loginRequestBody.gender = .male
        showSignUpName?(loginRequestBody)
    }
    
    @objc private func girlAction(_ sender: UITapGestureRecognizer) {
        girlImageView.backgroundColor = .white
        boyImageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        loginRequestBody.gender = .female
        showSignUpName?(loginRequestBody)

    }
   
}

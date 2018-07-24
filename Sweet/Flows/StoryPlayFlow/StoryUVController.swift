//
//  StoryUVController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol StoryUVControllerDelegate: NSObjectProtocol {
    func closeStoryUV()
}
class StoryUVController: BaseViewController {
    var runProfileFlow: ((UInt64) -> Void)?
    weak var delegate: StoryUVControllerDelegate?
    var user: User
    private let storyId: UInt64
    private var storyUvList: StoryUvList?
    private lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: .zero)
        view.titleLabel.text = "还没有人看过你的小故事"
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        button.addTarget(self, action: #selector(didPressClose(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomClearButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressClose(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(StoryUVTableViewCell.self, forCellReuseIdentifier: "storyUVCell")
        
        return tableView
    }()
    
    init(storyId: UInt64, user: User) {
        self.storyId = storyId
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStoryUvlist()
    }   
    
    private func loadStoryUvlist() {
        web.request(.storyDetailsUvlist(storyId: storyId),
                    responseType: Response<StoryUvList>.self) { [weak self] (result) in
            switch result {
            case let .success(response):
                self?.storyUvList = response
                self?.likeCountLabel.text = response.likeCount == 0 ? "暂无获赞" : "获赞\(response.likeCount)"
                self?.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(likeCountLabel)
        likeCountLabel.align(.left, to: view, inset: 20)
        likeCountLabel.align(.top, to: view, inset: 20 + UIScreen.safeTopMargin())
        likeCountLabel.constrain(height: 30)
        view.addSubview(closeButton)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.centerY(to: likeCountLabel)
        closeButton.constrain(width: 30, height: 30)
        view.addSubview(tableView)
        tableView.fill(in: view, top: 60 + UIScreen.safeTopMargin(), bottom: 50 + 35 + 25 + UIScreen.safeBottomMargin())
        view.addSubview(bottomClearButton)
        bottomClearButton.constrain(width: 50, height: 50)
        bottomClearButton.centerX(to: view)
        bottomClearButton.align(.bottom, inset: 25 + UIScreen.safeBottomMargin())
    }
    
    @objc private func didPressClose(sender: UIButton) {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        delegate?.closeStoryUV()
    }
}

extension StoryUVController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyUvList?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                            withIdentifier: "storyUVCell",
                            for: indexPath) as? StoryUVTableViewCell else { fatalError() }
        if let model = storyUvList?.list[indexPath.row] {
            cell.update(model)
        }
        return cell
    }
}

extension StoryUVController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        runProfileFlow?(storyUvList!.list[indexPath.row].userId)
    }
}

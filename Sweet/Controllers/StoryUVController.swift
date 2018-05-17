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
    weak var delegate: StoryUVControllerDelegate?
    private let storyId: UInt64
    private var storyUvList: StoryUvList?
    private lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: .zero)
        view.titleLabel.text = "还没有人看过你的小故事"
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsets(top: -14, left: 14, bottom: 0, right: 0)
        button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
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
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(StoryUVTableViewCell.self, forCellReuseIdentifier: "storyUVCell")
        return tableView
    }()
    
    init(storyId: UInt64) {
        self.storyId = storyId
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
        web.request(.storyDetailsUvlist(storyId: storyId), responseType: Response<StoryUvList>.self) { (result) in
            switch result {
            case let .success(response):
                self.storyUvList = response
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        closeButton.align(.right, to: view, inset: 20)
        closeButton.align(.top, to: view, inset: UIScreen.isIphoneX() ? 64 : 20)
        closeButton.constrain(width: 40, height: 40)
        view.addSubview(likeCountLabel)
        likeCountLabel.align(.left, to: view, inset: 20)
        likeCountLabel.align(.top, to: view, inset: UIScreen.isIphoneX() ? 64 : 20)
        likeCountLabel.constrain(height: 30)
        view.addSubview(tableView)
        tableView.fill(in: view, top: UIScreen.isIphoneX() ? 64 + 40 : 20 + 40 )
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
    
}

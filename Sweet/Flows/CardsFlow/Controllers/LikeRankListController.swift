//
//  LikeRankListController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol LikeRankListViewDelegate: class {
    func showProfile(userId: UInt64, setTop: SetTop?)
}

protocol LikeRankListView: BaseView {
    var delegate: LikeRankListViewDelegate? { get set }
}
class LikeRankListController: BaseViewController, LikeRankListView {
    weak var delegate: LikeRankListViewDelegate?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSize(width: UIScreen.mainWidth(), height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RankingCollectionViewCell.self, forCellWithReuseIdentifier: "rankingCell")
        return collectionView
    }()
    private var viewModels = [LikeRankViewModel]()
    private var rankChangeNum = 0
    private var titleString: String
    init(title: String) {
        self.titleString = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItemTitleView()
        view.addSubview(collectionView)
        collectionView.fill(in: view)
        requestLikeRankList(start: nil, end: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setNavigationItemTitleView() {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.lineBreakMode = .byTruncatingMiddle
        label.text = titleString
        navigationItem.titleView = label
    }
    
    
    private func requestLikeRankList(start: Int?, end: Int?) {
        web.request(WebAPI.likeRankList(start: start, end: end), responseType: Response<LikeRank>.self) { (result) in
            switch result {
            case let .success(response):
                self.rankChangeNum = response.rankChangeNum
                var indexPath = IndexPath(row: 0, section: 0)
                self.viewModels = response.rankList.map( {
                    var viewModel = LikeRankViewModel(model: $0)
                    viewModel.showProfile = { [weak self] (userId, setTop) in
                        self?.delegate?.showProfile(userId: userId, setTop: setTop)
                    }
                   
                    return viewModel
                })
                self.viewModels = self.viewModels.map({
                    var viewModel = $0
                    if let IDString = Defaults[.userID], let userID = UInt64(IDString), userID == viewModel.userId {
                        indexPath.row = Int(viewModel.index - 1)
                        if response.rankChangeNum >= 0 {
                            if viewModel.index == 1 {
                                viewModel.commentString = "一览众山小"
                            } else {
                                viewModel.commentString = "超过上一位还需\(Int(self.viewModels[Int(viewModel.index - 1) - 1].likeCount) - Int(viewModel.likeCount + 1))❤️"
                            }
                        } else {
                            viewModel.commentString = "回到之前的排名还需\(Int(self.viewModels[Int(viewModel.index - 1) + response.rankChangeNum].likeCount) - Int(viewModel.likeCount))❤️"
                        }
                    }
                    return viewModel
                })
                self.collectionView.reloadData()
                if indexPath.row > 3 {
                    self.collectionView.performBatchUpdates(nil, completion: { (_) in
                        self.collectionView.contentOffset.y += 61 * CGFloat(indexPath.row + 1 - 4)
                    })
                }
            case let .failure(error):
                logger.error(error)
            }
        }
    }

}

extension LikeRankListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rankingCell", for: indexPath) as? RankingCollectionViewCell else { fatalError() }
        cell.update(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension LikeRankListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModels[indexPath.row].showProfile?(viewModels[indexPath.row].userId, nil)
    }
}

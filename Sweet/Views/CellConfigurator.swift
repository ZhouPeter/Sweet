//
//  CellConfigurator.swift
//  XPro
//
//  Created by Mario Z. on 2018/1/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol CellReusable: class {
    static var reuseIdentifier: String { get }
}

extension CellReusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    final func register<T: UICollectionViewCell>(cellType: T.Type) where T: CellReusable {
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func registerNib<T: UICollectionViewCell>(forCellType cellType: T.Type) where T: CellReusable {
        self.register(
            UINib(nibName: cellType.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: cellType.reuseIdentifier
        )
    }
    
    final func dequeueReusableCell<T: UICollectionViewCell>(
            for indexPath: IndexPath,
            cellType: T.Type = T.self
        ) -> T where T: CellReusable {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
}

extension UITableView {
    final func register<T: UITableViewCell>(cellType: T.Type) where T: CellReusable {
        self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func registerNib<T: UITableViewCell>(forCellType cellType: T.Type) where T: CellReusable {
        self.register(
            UINib(nibName: cellType.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: cellType.reuseIdentifier
        )
    }
    
    final func dequeueReusableCell<T: UITableViewCell>(
            for indexPath: IndexPath,
            cellType: T.Type = T.self
        ) -> T where T: CellReusable {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError()
        }
        return cell
    }
}

protocol CellUpdatable {
    associatedtype ViewModelType
    func updateWith(_ viewModel: ViewModelType)
}

protocol CellConfiguratorType {
    var reuseIdentifier: String { get }
    var cellClass: AnyClass { get }
    func configure(_ cell: UIView)
}

struct CellConfigurator<Cell> where Cell: CellUpdatable, Cell: CellReusable {
    var viewModel: Cell.ViewModelType
    let reuseIdentifier = Cell.self.reuseIdentifier
    let cellClass: AnyClass = Cell.self
    func configure(_ cell: UIView) {
        if let cell = cell as? Cell {
            cell.updateWith(viewModel)
        }
    }
}

extension CellConfigurator: CellConfiguratorType {}

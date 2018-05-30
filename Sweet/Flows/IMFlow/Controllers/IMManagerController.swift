//
//  IMManagerController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol IMManagerView: BaseView {
    var showIMList: ((IMListView) -> Void)? { get set }
    var showIMContacts: ((IMContactsView) -> Void)? { get set }

}
class IMManagerController: BaseViewController, IMManagerView {
    var showIMList: ((IMListView) -> Void)?
    
    var showIMContacts: ((IMContactsView) -> Void)?
    
    var iMListController = IMListController()
    var contactsController = IMContactsController()
    private var currentController = UIViewController()
    private lazy var titleView: UISegmentedControl = {
        let control = UISegmentedControl(items: ["消息", "联系人"])
        control.tintColor = .clear
        let normalTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                    NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        control.setTitleTextAttributes(normalTextAttributes, for: .normal)
        let selectedTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                      NSAttributedStringKey.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(changeController(_:)), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.titleView = titleView
        addChildViewController(iMListController)
        iMListController.didMove(toParentViewController: self)
        view.addSubview(iMListController.view)
        currentController = iMListController
        showIMList?(iMListController)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.xpNavBlue()
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc private func changeController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.replaceController(oldController: currentController, newController: iMListController)
        } else {
            self.replaceController(oldController: currentController, newController: contactsController)
        }
    }
    
    private func replaceController(oldController: UIViewController, newController: UIViewController) {
        if oldController == newController { return }
        addChildViewController(newController)
        newController.didMove(toParentViewController: self)
        view.addSubview(newController.view)
        oldController.willMove(toParentViewController: nil)
        oldController.removeFromParentViewController()
        oldController.view.removeFromSuperview()
        self.currentController = newController
        if newController is IMListController {
            showIMList?(iMListController)
        } else {
            showIMContacts?(contactsController)
        }
    }
    
}

//
//  Created by lili on 2018/5/18.
//
//  Copyright © 2018年 fun. All rights reserved.
//

import UIKit

class FunNavigationViewController: UINavigationController {

    private var topViewControllerNavBarStyle: UIBarStyle? {
        return (topViewController as? NavBarStyleChangeable)?.barStyle
    }
    
    private func setNavBarStyle(_ barStyle: UIBarStyle) {
        navigationBar.barStyle = barStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let barStyle = topViewControllerNavBarStyle {
            setNavBarStyle(barStyle)
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        if let barStyle = topViewControllerNavBarStyle {
            setNavBarStyle(barStyle)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popViewController = super.popViewController(animated: animated)
        
        if let barStyle = topViewControllerNavBarStyle {
            setNavBarStyle(barStyle)
        }
        transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] _ in
            if let barStyle = self?.topViewControllerNavBarStyle {
                self?.setNavBarStyle(barStyle)
            }
        }
        return popViewController
    }
}

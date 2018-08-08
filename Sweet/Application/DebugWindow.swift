//
//  DebugWindow.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/26.
//  Copyright © 2018 Miaozan. All rights reserved.
//

#if DEBUG
import UIKit
import FLEX

final class DebugWindow: UIWindow {
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        FLEXManager.shared()?.toggleExplorer()
        super.motionEnded(motion, with: event)
    }
}
#endif

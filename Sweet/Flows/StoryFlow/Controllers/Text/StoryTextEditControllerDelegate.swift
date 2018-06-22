//
//  StoryTextEditControllerDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryTextEditControllerDelegate: class {
    func storyTextEditControllerDidBeginEditing()
    func storyTextEidtControllerDidEndEditing()
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer)
    func storyTextEditControllerTextDeleteZoneDidBeginUpdate(_ rect: CGRect)
    func storyTextEditControllerTextDeleteZoneDidUpdate(_ rect: CGRect)
    func storyTextEditControllerTextDeleteZoneDidEndUpdate(_ rect: CGRect)
    func storyTextEditControllerDidBeginChooseTopic()
    func storyTextEditControllerDidEndChooseTopic(_ topic: String?)
}

extension StoryTextEditControllerDelegate {
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer) {}
    func storyTextEditControllerTextDeleteZoneDidBeginUpdate(_ rect: CGRect) {}
    func storyTextEditControllerTextDeleteZoneDidUpdate(_ rect: CGRect) {}
    func storyTextEditControllerTextDeleteZoneDidEndUpdate(_ rect: CGRect) {}
    func storyTextEditControllerDidBeginChooseTopic() {}
    func storyTextEditControllerDidEndChooseTopic(_ topic: String?) {}
}

//
//  StoryRecordView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryRecordView: BaseView {
    var onRecorded: ((_ fileURL: URL, _ isPhoto: Bool, _ topic: String?) -> Void)? { get set }
    var onTextChoosed: ((String?) -> Void)? { get set }
    var onAlbumChoosed: ((String?) -> Void)? { get set }
    var onDismissed: (() -> Void)? { get set }
    var onAvatarButtonPressed: (() -> Void)? { get set }
    var isAvatarCircleAnamtionEnabled: Bool { get set }
    
    func prepare()
    func chooseCameraRecord()
}

//
//  MessageHandler.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import libimcloud
import SwiftProtobuf

class MessageHandler<T>: BaseHandler where T: Message {
    var callback: ((T?) -> Void)?
    
    init(callback: ((T?) -> Void)?) {
        self.callback = callback
        super.init()
    }
    
    override func handlePackage(_ package: ImPackageRawdata!) {
        guard let data = package.body else {
            callback?(nil)
            return
        }
        do {
            let result = try T(serializedData: data)
            callback?(result)
        } catch {
            logger.error(error)
            callback?(nil)
        }
    }
}

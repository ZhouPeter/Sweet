//
//  DeliverOperation.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import libimcloud
import SwiftProtobuf

class DeliverTask<Response>: AsynchronousOperation where Response: Message {
    private let service: ImCloudService
    private let package: ImPackageRawdata
    private let module: Int
    private let command: Int
    private var callback: ((UInt, Response?) -> Void)?
    
    init(service: ImCloudService,
         package: ImPackageRawdata,
         module: Int,
         command: Int,
         callback: ((UInt, Response?) -> Void)? = nil) {
        self.service = service
        self.package = package
        self.module = module
        self.command = command
        self.callback = callback
    }
    
    override func main() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
        HandlerManager
            .sharedInstance()
            .addHandler(module, commandId: command + 1, handler: MessageHandler<Response>(callback: { [weak self] (message) in
                guard let `self` = self else { return }
                self.state = .finished
                self.callback?(0, message)
        }))
        service.send(package, moduleId: module, commandId: command) { [weak self] (code) in
            guard let `self` = self else { return }
            if code.rawValue != 0 {
                self.state = .finished
                self.callback?(code.rawValue, nil)
            }
        }
    }
}

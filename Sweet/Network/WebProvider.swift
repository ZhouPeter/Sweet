//
//  WebProvider.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya

let web = WebProvider()

final class WebProvider {
    let tokenSource = TokenSource()
    
    private lazy var provider = MoyaProvider<WebAPI>(
        plugins: [
            SignPlugin(signClosure: Signer.sign),
            AuthPlugin(tokenClosure: { self.tokenSource.token })
        ]
    )
    
    func request(_ api: WebAPI, completion: () -> Void) -> Cancellable {
        return provider.request(api, completion: { (result) in
            switch result {
            case let .failure(error):
                logger.error(error)
            case let .success(response):
                logger.debug(response)
            }
        })
    }
}

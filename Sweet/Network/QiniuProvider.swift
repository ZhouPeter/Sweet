//
//  QiniuProvider.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya
import Result

let qiniu = QiniuProvider()
class QiniuProvider {
    private lazy var provider = MoyaProvider<QiniuAPI>(
        plugins: []
    )
    
    @discardableResult func requestUpload(
        api: QiniuAPI,
        completion: @escaping (Result<[String: Any], NSError>) -> Void) -> Cancellable {
        return provider.request(api, progress: { (_) in
            
        }, completion: { result in
            switch result {
            case let .failure(error):
                logger.error(error)
                completion(.failure(NSError(code: .http)))
            case let .success(response):
                do {
                    if let json = (try response.mapJSON(failsOnEmptyData: true)) as? [String: Any] {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(code: .parse)))
                    }
                } catch {
                    logger.error(error)
                    completion(.failure(NSError(code: .parse)))
                }
            }
        })
    }
}

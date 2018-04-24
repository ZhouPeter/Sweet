//
//  WebProvider.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya
import Result

let web = WebProvider()

final class WebProvider {
    let tokenSource = TokenSource()
    
    private lazy var provider = MoyaProvider<WebAPI>(
        plugins: [
            SignPlugin(signClosure: Signer.sign),
            AuthPlugin(tokenClosure: { self.tokenSource.token })
//            NetworkLoggerPlugin(verbose: true)
        ]
    )
    
    @discardableResult func request<T>(
        _ api: WebAPI,
        responseType: T.Type,
        completion: @escaping (Result<T, NSError>) -> Void) -> Cancellable where T: Codable {
        return provider.request(api, completion: { (result) in
            switch result {
            case let .failure(error):
                logger.error(error)
                completion(.failure(NSError(code: .http)))
            case let .success(response):
                do {
                    let model = try JSONDecoder().decode(responseType, from: response.data)
                    completion(.success(model))
                } catch {
                    logger.error(error)
                    completion(.failure(NSError(code: .parse)))
                }
            }
        })
    }
    
    @discardableResult func request(
        _ api: WebAPI,
        completion: @escaping (Result<[String: Any], NSError>) -> Void) -> Cancellable {
        return provider.request(api, completion: { (result) in
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

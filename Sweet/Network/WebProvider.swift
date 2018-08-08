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
import SwiftyUserDefaults
let web = WebProvider()
let logoutNotiName = "notificationLogout"
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
        responseType: Response<T>.Type,
        completion: @escaping (Result<T, NSError>) -> Void) -> Cancellable where T: Codable {
        return provider.request(api, completion: { (result) in
            switch result {
            case let .failure(error):
                logger.error(error)
                completion(.failure(NSError(code: .http)))
            case let .success(response):
                guard response.statusCode == 200 else {
                    if response.statusCode == 401 {
                        WebProvider.logout()
                        return
                    }
                    completion(.failure(NSError(code: .http)))
                    return
                }
                do {
                    let responseBody = try JSONDecoder().decode(responseType, from: response.data)
                    if responseBody.code == 0 {
                        completion(.success(responseBody.data!))
                    } else if responseBody.code == WebErrorCode.authorization.rawValue {
                       WebProvider.logout()
                    } else {
                        completion(.failure(NSError(code: responseBody.code)))
                    }
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
                guard response.statusCode == 200 else {
                    if response.statusCode == 401 {
                        WebProvider.logout()
                        return
                    }
                    completion(.failure(NSError(code: .http)))
                    return
                }
                do {                                      
                    if let json = (try response.mapJSON(failsOnEmptyData: true)) as? [String: Any],
                        let code = json["code"] as? Int {
                        if code == 0, let data = json["data"] as? [String: Any] {
                            completion(.success(data))
                        } else if code == WebErrorCode.authorization.rawValue {
                            WebProvider.logout()
                        } else {
                            completion(.failure(NSError(code: code)))
                        }
                    }
                } catch {
                    logger.error(error)
                    completion(.failure(NSError(code: .parse)))
                }
            }
        })
    }
    
}

extension WebProvider {
    class func logout() {
        LoginResponse.remove()
        Defaults.remove(.token)
        Defaults.remove(.userID)
        web.tokenSource.token = nil
        Messenger.shared.logout()
        NotificationCenter.default.post(name: NSNotification.Name(logoutNotiName), object: nil)
    }
}

//
//  Upload.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya
class Upload {
    class func uploadFileToQiniu(localURL: URL,
                                 type: UploadType,
                                 completion: @escaping (UploadTokenResponse?, NSError?) -> Void) {
        web.request(.upload(type: .userAvatar)) { (result) in
            switch result {
            case  let .success(response):
                if  let uploadToken = response["uploadToken"] as? [String: Any],
                    let token = uploadToken["token"] as? String,
                    let key = uploadToken["key"]  as? String {
                    qiniu.requestUpload(
                        api: .uploadFile(token: token,
                                         key: key,
                                         fileURL: localURL,
                                         type: type),
                        completion: { (qiniuResult) in
                            switch qiniuResult {
                            case .success:
                                let model = try? JSONDecoder().decode(UploadTokenResponse.self, from: uploadToken)
                                completion(model, nil)
                            case let .failure(error):
                                logger.error(error)
                            }
                    })
                } else {
                    completion(nil, NSError(code: .parse))
                }
            case let .failure(error):
                logger.error(error)
                completion(nil, error)
            }
        }
    }
}

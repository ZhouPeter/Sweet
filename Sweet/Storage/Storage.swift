//
//  Storage.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

final class Storage {
    let userID: UInt64
    
    var realm: Realm {
        let realmURL = URL.userDirectory(with: userID).appendingPathComponent("data.realm")
        let schemaVersion: UInt64 = 1
        let config = Realm.Configuration(
            fileURL: realmURL,
            schemaVersion: schemaVersion,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true
        )
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    lazy var dataQueue = DispatchQueue(label: "Storage.Data")
    
    init(userID: UInt64) {
        self.userID = userID
    }
    
    func write(
        _ block: @escaping (Realm) -> Void,
        callbackQueue: DispatchQueue? = nil,
        callback: ((Bool) -> Void)? = nil) {
        dataQueue.async { [weak self] in
            guard let `self` = self else { return }
            var succeed = true
            do {
                let realm = self.realm
                try realm.write { block(realm) }
            } catch {
                logger.error(error)
                succeed = false
            }
            if let callback = callback {
                if let queue = callbackQueue {
                    queue.async { callback(succeed) }
                } else {
                    DispatchQueue.main.async { callback(succeed) }
                }
            }
        }
    }
    
    func read(_ block: @escaping (Realm) -> Void, callbackQueue: DispatchQueue? = nil, callback: (() -> Void)? = nil) {
        dataQueue.async { [weak self] in
            guard let `self` = self else { return }
            block(self.realm)
            if let callback = callback {
                if let queue = callbackQueue {
                    queue.async { callback() }
                } else {
                    DispatchQueue.main.async { callback() }
                }
            }
        }
    }
}

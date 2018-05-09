//
//  URL+Path.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension URL {
    func createDirectoryIfNeeded() -> URL {
        var isDirectory: ObjCBool = true
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) == false {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.error(error)
            }
        }
        return self
    }
    
    func remove() -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                 try fileManager.removeItem(at: self)
                 return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
}

extension URL {
    static var fileManager: FileManager {
      return FileManager.default
    }
    
    static func userDirectory(with userID: UInt64) -> URL {
        let documentURL = userDomain(for: .documentDirectory)
        return documentURL.appendingPathComponent("\(userID)", isDirectory: true).createDirectoryIfNeeded()
    }
    
    static func userDomain(for directory: FileManager.SearchPathDirectory) -> URL {
        return fileManager.urls(for: directory, in: .userDomainMask).first!
    }
    
    static func cachesURL() -> URL {
        return userDomain(for: .cachesDirectory).createDirectoryIfNeeded()
    }
    
    static func cachesURL(withName name: String) -> URL {
        return cachesURL().appendingPathComponent(name)
    }
    
    static func avatarCachesURL() -> URL {
        let cachesURL = userDomain(for: .cachesDirectory)
        return  cachesURL.appendingPathComponent("Avatars", isDirectory: true).createDirectoryIfNeeded()
    }
    
    static func avatarCachesURL(withName name: String) -> URL {
        return avatarCachesURL().appendingPathComponent(name)
    }
    
    static func videoCacheURL(withName name: String) -> URL {
        return cachesURL()
            .appendingPathComponent("Videos", isDirectory: true)
            .createDirectoryIfNeeded()
            .appendingPathComponent(name)
    }
    
    static func photoCacheURL(withName name: String) -> URL {
        return cachesURL()
            .appendingPathComponent("Photos", isDirectory: true)
            .createDirectoryIfNeeded()
            .appendingPathComponent(name)
    }
}

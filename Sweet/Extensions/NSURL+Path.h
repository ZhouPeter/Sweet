//
//  NSURL+Path.h
//  XPro
//
//  Created by Mario Z. on 2017/11/3.
//  Copyright © 2017年 Miaozan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Path)

+ (NSURL *)userDirectoryWithUserID:(long)userID;
+ (NSURL *)cacheURLWithName:(NSString *)name;
+ (NSURL *)avatarCacheURLWithName:(NSString *)name;
+ (NSURL *)imLogsURLWithName:(NSString *)name;
+ (NSURL *)videoCacheURLWithName:(NSString *)name;
+ (NSURL *)photoCacheURLWithName:(NSString *)name;
+ (NSURL *)audioCacheURLWithName:(NSString *)name;
- (BOOL)remove;
- (BOOL)fileExistsAtPath;

@end

NS_ASSUME_NONNULL_END

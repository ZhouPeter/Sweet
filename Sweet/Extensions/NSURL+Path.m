//
//  NSURL+Path.m
//  XPro
//
//  Created by Mario Z. on 2017/11/3.
//  Copyright © 2017年 Miaozan. All rights reserved.
//

#import "NSURL+Path.h"

@implementation NSURL (Path)

+ (NSURL *)userDirectoryWithUserID:(long)userID {
    NSURL *documentURL = [self userDomainURLForDirectory:NSDocumentDirectory];
    return [[documentURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld", userID]
                                         isDirectory:YES] createDirectoryIfNeeded];
}

+ (NSURL *)userDomainURLForDirectory:(NSSearchPathDirectory)directory {
    return [[NSFileManager defaultManager] URLsForDirectory:directory inDomains:NSUserDomainMask].firstObject;
}

- (NSURL *)createDirectoryIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:self.path isDirectory:&isDirectory] == NO) {
        [fileManager createDirectoryAtPath:self.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}
+ (NSURL *)cachesURL {
    return [[self userDomainURLForDirectory:NSCachesDirectory] createDirectoryIfNeeded];
}

+ (NSURL *)cacheURLWithName:(NSString *)name{
    if (!name) { return nil; }
    return [[self cachesURL] URLByAppendingPathComponent:name];
}

+ (NSURL *)avatarCachesURL {
    NSURL *cachesURL = [self userDomainURLForDirectory:NSCachesDirectory];
    return [[cachesURL URLByAppendingPathComponent:@"Avatars" isDirectory:YES] createDirectoryIfNeeded];
}

+ (NSURL *)avatarCacheURLWithName:(NSString *)name {
    if (!name) { return nil; }
    return [[self avatarCachesURL] URLByAppendingPathComponent:name];
}

+ (NSURL *)imLogsURLWithName:(NSString *)name {
    NSURL *cachesURL = [self userDomainURLForDirectory:NSCachesDirectory];
    NSURL *url = [[cachesURL URLByAppendingPathComponent:@"IMLogs" isDirectory:YES] createDirectoryIfNeeded];
    return [url URLByAppendingPathComponent:name];
}

+ (NSURL *)videoCacheURLWithName:(NSString *)name {
    NSURL *cachesURL = [self userDomainURLForDirectory:NSCachesDirectory];
    return [[[cachesURL URLByAppendingPathComponent:@"Videos" isDirectory:YES]
             createDirectoryIfNeeded]
            URLByAppendingPathComponent:name];
}

+ (NSURL *)photoCacheURLWithName:(NSString *)name {
    NSURL *cachesURL = [self userDomainURLForDirectory:NSCachesDirectory];
    return [[[cachesURL URLByAppendingPathComponent:@"Photos" isDirectory:YES]
             createDirectoryIfNeeded]
            URLByAppendingPathComponent:name];
}

+ (NSURL *)audioCacheURLWithName:(NSString *)name {
    NSURL *cachesURL = [self userDomainURLForDirectory:NSCachesDirectory];
    return [[[cachesURL URLByAppendingPathComponent:@"Audio" isDirectory:YES]
             createDirectoryIfNeeded]
            URLByAppendingPathComponent:name];
}

- (BOOL)remove {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        return [[NSFileManager defaultManager] removeItemAtURL:self error:nil];
    }
    return NO;
}


-(BOOL)fileExistsAtPath{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.path];
}
@end

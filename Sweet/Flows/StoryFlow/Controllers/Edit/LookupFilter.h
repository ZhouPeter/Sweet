//
//  LookupFilter.h
//  filter-demo
//
//  Created by Mario Z. on 2017/12/4.
//  Copyright © 2017年 Mario Z. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImageFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface LookupFilter : GPUImageFilterGroup

- (instancetype)initWithLookupImage:(UIImage *)image;
+ (instancetype)defaultFilter;

@end

NS_ASSUME_NONNULL_END

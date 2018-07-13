//
//  LookupFilter.m
//  filter-demo
//
//  Created by Mario Z. on 2017/12/4.
//  Copyright © 2017年 Mario Z. All rights reserved.
//

#import "LookupFilter.h"

@interface LookupFilter()

@property (strong, nonatomic) GPUImagePicture *lookupImageSource;

@end

@implementation LookupFilter

- (instancetype)initWithLookupImage:(UIImage *)image {
    if (self = [super init]) {
        self.lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageLookupFilter *filter = [GPUImageLookupFilter new];
        filter.intensity = 0.75;
        [self addFilter:filter];
        
        [self.lookupImageSource addTarget:filter atTextureLocation:1];
        [self.lookupImageSource processImage];
        
        self.initialFilters = [NSArray arrayWithObjects:filter, nil];
        self.terminalFilter = filter;
    }
    return self;
}

+ (instancetype)defaultFilter {
    return [[LookupFilter alloc] initWithLookupImage:[UIImage imageNamed:@"NA"]];
}

@end

//
//  StoryFilterPreviewController.h
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LookupFilter;
@interface StoryFilterPreviewController : UIViewController

- (instancetype)initWithFileURL:(NSURL *)url isPhoto:(BOOL)isPhoto;
- (void)stopPreview;
- (void)didPan:(UIPanGestureRecognizer *)recognizer;
- (LookupFilter *)currentFilter;

@end

NS_ASSUME_NONNULL_END

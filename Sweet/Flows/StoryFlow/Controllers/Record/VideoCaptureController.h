//
//  VideoCaptureController.h
//  Sweet
//
//  Created by Mario Z. on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCaptureController : NSObject

@property (assign, nonatomic) BOOL isFlashOn;
@property (assign, nonatomic) BOOL isFrontCamera;

- (void)renderInView:(UIView *)view;
- (BOOL)startPreview;
- (void)stopPreview;
- (void)startRecord;
- (void)finishRecordForPhotoCapture:(BOOL)isPhotoCapture completion:(void (^)(NSURL  * _Nullable fileURL))completion;
- (void)cancelRecord;

@end

NS_ASSUME_NONNULL_END

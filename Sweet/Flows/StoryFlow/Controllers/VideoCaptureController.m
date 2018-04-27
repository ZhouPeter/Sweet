//
//  VideoCaptureController.m
//  Sweet
//
//  Created by Mario Z. on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import "VideoCaptureController.h"
#import <GPUImage/GPUImage.h>

@interface VideoCaptureController ()

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) GPUImageView *renderView;
@property (assign, nonatomic) BOOL isCapturing;

@end

@implementation VideoCaptureController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.camera =
        [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                            cameraPosition:AVCaptureDevicePositionBack];
        self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}

#pragma mark - Public

- (void)renderInView:(UIView *)view {
    if (self.renderView) {
        [self.renderView removeFromSuperview];
        self.renderView = nil;
    }
    self.renderView = [[GPUImageView alloc] initWithFrame:view.bounds];
    [view addSubview:self.renderView];
}

- (BOOL)startPreview {
    if (!self.renderView || self.isCapturing) {
        return NO;
    }
    self.isCapturing = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.camera addTarget:self.renderView];
    [self.camera startCameraCapture];
    return YES;
}

- (void)stopPreview {
    self.isCapturing = NO;
    [self.camera stopCameraCapture];
}

- (void)startRecord {
    
}

- (void)finishRecordForPhotoCapture:(BOOL)isPhotoCapture completion:(void (^)(NSURL * _Nullable))completion {
    
}

- (void)cancelRecord {
    
}

#pragma mark - Setters & Getters



@end

//
//  VideoCaptureController.m
//  Sweet
//
//  Created by Mario Z. on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import "VideoCaptureController.h"
#import <GPUImage/GPUImage.h>
#import "NSURL+Path.h"

@interface VideoCaptureController ()

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) GPUImageView *renderView;
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (assign, nonatomic) BOOL isCapturing;
@property (assign, nonatomic) BOOL isRecording;

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
    if (self.isRecording) {
        return;
    }
    self.isRecording = YES;
    if (!self.movieWriter) {
        CGSize size = self.renderView.bounds.size;
        size.height = size.width * (16.0 / 9.0);
        CGSize renderSize = CGSizeMake(floor(size.width / 16) * 16, floor(size.height / 16) * 16);
        NSURL *url = [self makeVideoURL];
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:renderSize];
    }
    [self turnOnFlash:self.isFlashOn];
    self.camera.audioEncodingTarget = self.movieWriter;
    [self.camera addTarget:self.movieWriter];
    [self.movieWriter startRecording];
}

- (void)finishRecordForPhotoCapture:(BOOL)isPhotoCapture completion:(void (^)(NSURL * _Nullable))completion {
    if (!self.isRecording) {
        if (completion) { completion(nil); }
        return;
    }
    self.isRecording = NO;
    if (isPhotoCapture) {
        [self cancelRecord];
        [self takeAPhotoWithCallback:completion];
    } else {
        [self.movieWriter finishRecording];
        [self.camera removeTarget:self.movieWriter];
        NSURL *url = self.movieWriter.assetWriter.outputURL;
        self.movieWriter = nil;
        [self turnOnFlash:NO];
        if (completion) {
            completion(url);
        }
    }
}

- (void)cancelRecord {
    self.isRecording = NO;
    if (self.movieWriter) {
        [self.movieWriter cancelRecording];
        [self.camera removeTarget:self.movieWriter];
        NSURL *url = self.movieWriter.assetWriter.outputURL;
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        self.movieWriter = nil;
    }
    [self turnOnFlash:NO];
}

#pragma mark - Setters & Getters

- (void)setIsFrontCamera:(BOOL)isFrontCamera {
    if (_isFrontCamera == isFrontCamera) { return; }
    _isFrontCamera = isFrontCamera;
    [self.camera rotateCamera];
}

#pragma mark - Private

- (void)takeAPhotoWithCallback:(void (^)(NSURL *fileURL))callback {
    [self turnOnFlash:self.isFlashOn];
    GPUImageOpacityFilter *filter = [GPUImageOpacityFilter new];
    [self.camera addTarget:filter];
    
    [filter useNextFrameForImageCapture];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIImage *image = [filter imageFromCurrentFramebuffer];
        [weakSelf.camera removeTarget:filter];
        NSURL *url = nil;
        if (image) {
            url = [weakSelf makePhotoURL];
            [UIImageJPEGRepresentation(image, 0.8) writeToURL:url atomically:YES];
        }
        if (callback) { callback(url); }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf turnOnFlash:NO];
        });
    });
}

- (NSURL *)makeVideoURL {
    return [NSURL videoCacheURLWithName:[NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString]];
}

- (NSURL *)makePhotoURL {
    return [NSURL photoCacheURLWithName:[NSString stringWithFormat:@"%@.jpg", [NSUUID UUID].UUIDString]];
}

- (void)turnOnFlash:(BOOL)isOn {
    if (![self.camera.inputCamera hasTorch]) { return; }
    AVCaptureTorchMode mode = isOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    if (mode == self.camera.inputCamera.torchMode) { return; }
    [self.camera.inputCamera lockForConfiguration:nil];
    self.camera.inputCamera.torchMode = mode;
    [self.camera.inputCamera unlockForConfiguration];
}

@end

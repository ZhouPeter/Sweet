//
//  StoryFilterPreviewController.m
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>
#import "StoryFilterPreviewController.h"
#import "LookupFilter.h"
#import "XGPUImageMovie.h"

@interface StoryFilterPreviewController ()

@property (strong, nonatomic) GPUImageOutput *output;
@property (strong, nonatomic) GPUImageView *backgroundPreview;
@property (strong, nonatomic) GPUImageView *foregroundPreview;
@property (strong, nonatomic) NSArray *lookupImages;
@property (assign, nonatomic) BOOL isPanLeft;
@property (assign, nonatomic) BOOL isPanDirectionFixed;
@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) NSUInteger filterIndex;
@property (assign, nonatomic) BOOL isPhoto;
@property (strong, nonatomic) AVPlayer *audioPlayer;

@end

@implementation StoryFilterPreviewController

- (instancetype)initWithFileURL:(NSURL *)url isPhoto:(BOOL)isPhoto {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.isPhoto = isPhoto;
        if (isPhoto) {
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithURL:url];
            self.output = picture;
        } else {
            XGPUImageMovie *movie = [[XGPUImageMovie alloc] initWithURL:url];
            movie.playAtActualSpeed = YES;
            movie.shouldRepeat = YES;
            self.output = movie;
            self.audioPlayer = [[AVPlayer alloc] initWithURL:url];
            __weak typeof(self) weakSelf = self;
            movie.startProcessingCallback = ^{
                [weakSelf.audioPlayer seekToTime:kCMTimeZero];
                [weakSelf.audioPlayer play];
            };
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundPreview.userInteractionEnabled = NO;
    self.backgroundPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.backgroundPreview];
    
    self.foregroundPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.foregroundPreview.userInteractionEnabled = NO;
    self.foregroundPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.foregroundPreview.layer.contentsGravity = kCAGravityLeft;
    [self.view addSubview:self.foregroundPreview];
    
    self.lookupImages = @[[UIImage imageNamed:@"NA"],
                          [UIImage imageNamed:@"S"],
                          [UIImage imageNamed:@"Fe"],
                          [UIImage imageNamed:@"Cu"],
                          [UIImage imageNamed:@"C"]];
    [self.output addTarget:self.backgroundPreview];
    [self.output addTarget:self.foregroundPreview];
    if (self.isPhoto) {
        [(GPUImagePicture *)self.output processImage];
    } else {
        [(XGPUImageMovie *)self.output startProcessing];
    }
}

- (void)dealloc {
    [self stopPreview];
    [self.output removeAllTargets];
    [self.output removeOutputFramebuffer];
}

- (void)stopPreview {
    if (!self.isPhoto) {
        [(XGPUImageMovie *)self.output endProcessing];
        [self.audioPlayer pause];
    }
}

#pragma mark - Private

- (LookupFilter *)makeFilterWithIndex:(NSUInteger)index {
    return [[LookupFilter alloc] initWithLookupImage:self.lookupImages[index]];
}

#pragma mark - Actions

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat ratio = MAX(0, MIN(1, ABS(translation.x / self.view.bounds.size.width)));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isPanDirectionFixed = NO;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.isPanDirectionFixed) {
            if (translation.x < 0) {
                self.isPanLeft = YES;
            } else {
                self.isPanLeft = NO;
            }
            self.isPanDirectionFixed = YES;
            if (self.isPanLeft) {
                if (self.filterIndex < self.lookupImages.count - 1) {
                    LookupFilter *current = [self makeFilterWithIndex:self.filterIndex];
                    LookupFilter *newFilter = [self makeFilterWithIndex:self.filterIndex + 1];
                    
                    [self.output removeAllTargets];
                    
                    [self.output addTarget:current];
                    [current addTarget:self.foregroundPreview];
                    
                    [self.output addTarget:newFilter];
                    [newFilter addTarget:self.backgroundPreview];
                    
                    if (self.isPhoto) {
                        [(GPUImagePicture *)self.output processImage];
                    }
                } else {
                    self.filterIndex = 0;
                }
            } else {
                if (self.filterIndex > 0) {
                    LookupFilter *current = [self makeFilterWithIndex:self.filterIndex];
                    LookupFilter *newFilter = [self makeFilterWithIndex:self.filterIndex - 1];
                    
                    [self.output removeAllTargets];
                    
                    [self.output addTarget:newFilter];
                    [newFilter addTarget:self.foregroundPreview];
                    
                    [self.output addTarget:current];
                    [current addTarget:self.backgroundPreview];
                    
                    if (self.isPhoto) {
                        [(GPUImagePicture *)self.output processImage];
                    }
                } else {
                    self.filterIndex = self.lookupImages.count - 1;
                }
            }
        } else {
            if (self.isPanLeft) { ratio = 1 - ratio; }
            self.foregroundPreview.layer.contentsRect = CGRectMake(0, 0, ratio, 1);
        }
    } else {
        if (ratio > 0.1) {
            if (self.isPanLeft) {
                [self animateContentsRect:CGRectMake(0, 0, 0, 1) forLayer:self.foregroundPreview.layer];
                self.filterIndex += 1;
            } else {
                [self animateContentsRect:CGRectMake(0, 0, 1, 1) forLayer:self.foregroundPreview.layer];
                self.filterIndex -= 1;
            }
        } else {
            if (self.isPanLeft) {
                [self animateContentsRect:CGRectMake(0, 0, 1, 1) forLayer:self.foregroundPreview.layer];
            } else {
                [self animateContentsRect:CGRectMake(0, 0, 0, 1) forLayer:self.foregroundPreview.layer];
            }
        }
    }
}

- (void)animateContentsRect:(CGRect)rect forLayer:(CALayer *)layer {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contentsRect"];
    animation.fromValue = [NSValue valueWithCGRect:layer.contentsRect];
    animation.toValue = [NSValue valueWithCGRect:rect];
    animation.duration = 0.25;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:animation forKey:nil];
    layer.contentsRect = rect;
}

@end

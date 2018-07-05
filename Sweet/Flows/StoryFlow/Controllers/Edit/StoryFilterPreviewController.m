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
#import "GPUImageBeautifyFilter.h"

@interface StoryFilterPreviewController ()

@property (strong, nonatomic) GPUImageOutput *output;
@property (strong, nonatomic) GPUImageView *backPreview;
@property (strong, nonatomic) GPUImageView *forePreview;
@property (strong, nonatomic) NSMutableArray *lookupImages;
@property (assign, nonatomic) BOOL isNextFilter;
@property (assign, nonatomic) BOOL isDirectionConfirmed;
@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) NSUInteger filterIndex;
@property (assign, nonatomic) BOOL isPhoto;
@property (strong, nonatomic) AVPlayer *audioPlayer;

@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (assign, nonatomic) CGFloat maskRatio;
@property (strong, nonatomic) GPUImageBeautifyFilter *beautyFilter;
@property (strong, nonatomic) LookupFilter *backFilter;
@property (strong, nonatomic) LookupFilter *foreFilter;
@property (assign, nonatomic) BOOL isFilterSwitching;
@property (strong, nonatomic) NSMutableArray <NSString *> *filterNames;

@end

@implementation StoryFilterPreviewController

- (instancetype)initWithFileURL:(NSURL *)url isPhoto:(BOOL)isPhoto {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.isPhoto = isPhoto;
        self.beautyFilter = [[GPUImageBeautifyFilter alloc] init];
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
    [self setupPreviews];
    [self setupFilters];
    self.isFilterSwitching = NO;
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

- (LookupFilter *)currentFilter {
    return [self makeFilterWithIndex:self.filterIndex];
}

- (NSString *)currentFilterName {
    return self.filterNames[self.filterIndex];
}

#pragma mark - Private

- (void)setupPreviews {
    self.backPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.backPreview.userInteractionEnabled = NO;
    self.backPreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.backPreview];
    
    self.forePreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.forePreview.userInteractionEnabled = NO;
    self.forePreview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.forePreview];
    
    self.maskLayer = [CAShapeLayer layer];
    self.maskLayer.bounds = self.forePreview.bounds;
    self.maskLayer.fillColor = nil;
    self.maskLayer.strokeColor = [UIColor redColor].CGColor;
    self.maskLayer.position = CGPointMake(CGRectGetMidX(self.forePreview.bounds),
                                          CGRectGetMidY(self.forePreview.bounds));
    CGRect rect = self.forePreview.bounds;
    rect.size.width = 0;
    CGFloat halfHeight = CGRectGetMidY(self.forePreview.bounds);
    self.maskLayer.lineWidth = halfHeight * 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, halfHeight)];
    [path addLineToPoint:CGPointMake(self.forePreview.bounds.size.width, halfHeight)];
    self.maskLayer.path = path.CGPath;
    self.forePreview.layer.mask = self.maskLayer;
}

- (void)setupFilters {
    self.filterNames = [NSMutableArray array];
    self.lookupImages = [NSMutableArray array];
    for (int i = 1; i < 7; i++) {
        NSString *name = [NSString stringWithFormat:@"%d", i];
        [self.filterNames addObject:name];
        [self.lookupImages addObject:[UIImage imageNamed:name]];
    }
//    self.filterNames = @[@"NA", @"S", @"Fe", @"Cu", @"C"];
//    self.lookupImages = @[[UIImage imageNamed:@"NA"],
//                          [UIImage imageNamed:@"S"],
//                          [UIImage imageNamed:@"Fe"],
//                          [UIImage imageNamed:@"Cu"],
//                          [UIImage imageNamed:@"C"]];
    self.backFilter = [self makeFilterWithIndex:1];
    self.foreFilter = [self makeFilterWithIndex:0];
    
    [self.output addTarget:self.beautyFilter];
    
    [self.beautyFilter addTarget:self.backFilter];
    [self.backFilter addTarget:self.backPreview];
    
    [self.beautyFilter addTarget:self.foreFilter];
    [self.foreFilter addTarget:self.forePreview];
    
    if (self.isPhoto) {
        [(GPUImagePicture *)self.output processImage];
    } else {
        [(XGPUImageMovie *)self.output startProcessing];
    }
}

- (LookupFilter *)makeFilterWithIndex:(NSUInteger)index {
    return [[LookupFilter alloc] initWithLookupImage:self.lookupImages[index]];
}

- (void)exchangePreviews {
    [self.backPreview removeFromSuperview];
    [self.view addSubview:self.backPreview];
    
    GPUImageView *view = self.forePreview;
    self.forePreview = self.backPreview;
    self.backPreview = view;
    
    LookupFilter *filter = self.foreFilter;
    self.foreFilter = self.backFilter;
    self.backFilter = filter;
    
    self.backPreview.layer.mask = nil;
    self.forePreview.layer.mask = self.maskLayer;
}

- (void)setupNewFilter:(LookupFilter *)filter {
    [self.foreFilter removeAllTargets];
    [self.backFilter removeAllTargets];
    [self.beautyFilter removeAllTargets];
    [self.output removeAllTargets];
    self.backFilter = filter;
    [self.output addTarget:self.beautyFilter];
    [self.beautyFilter addTarget:self.foreFilter];
    [self.beautyFilter addTarget:self.backFilter];
    [self.foreFilter addTarget:self.forePreview];
    [self.backFilter addTarget:self.backPreview];
    if (self.isPhoto) {
        [(GPUImagePicture *)self.output processImage];
    }
}

#pragma mark - Actions

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    if (self.isFilterSwitching) { return; }
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat ratio = MAX(0, MIN(1, ABS(translation.x / self.view.bounds.size.width)));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isDirectionConfirmed = NO;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.isDirectionConfirmed) {
            if (translation.x < 0) {
                self.isNextFilter = YES;
            } else {
                self.isNextFilter = NO;
            }
            self.isDirectionConfirmed = YES;
            [self resetFiltersBeforePan];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.maskLayer.strokeStart = 0;
            self.maskLayer.strokeEnd = 1;
            [CATransaction commit];
            return;
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (self.isNextFilter) {
            self.maskLayer.strokeEnd = 1 - ratio;
        } else {
            self.maskLayer.strokeStart = ratio;
        }
        [CATransaction commit];
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.isDirectionConfirmed = NO;
        BOOL shouldSwitch = NO;
        if (self.isNextFilter) {
            if (1 - ratio > 0.1) { shouldSwitch = YES; }
        } else {
            if (ratio > 0.1) { shouldSwitch = YES; }
        }
        if (shouldSwitch) {
            self.isFilterSwitching = YES;
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.filterIndex = self.isNextFilter ? [self nextIndex] : [self previousIndex];
                [self resetFiltersAfterPan];
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [CATransaction setCompletionBlock:^{
                    self.isFilterSwitching = NO;
                }];
                self.maskLayer.strokeStart = 0;
                self.maskLayer.strokeEnd = 1;
                [CATransaction commit];
            }];
            if (self.isNextFilter) {
                self.maskLayer.strokeEnd = 0;
            } else {
                self.maskLayer.strokeStart = 1;
            }
            [CATransaction commit];
        } else {
            self.maskLayer.strokeStart = 0;
            self.maskLayer.strokeEnd = 1;
        }
        return;
    }
}

- (NSUInteger)nextIndex {
    if (self.filterIndex >= self.lookupImages.count - 1) {
        return 0;
    }
    return self.filterIndex + 1;
}

- (NSUInteger)previousIndex {
    if (self.filterIndex <= 0) {
        return self.lookupImages.count - 1;
    }
    return self.filterIndex - 1;
}

- (void)resetFiltersBeforePan {
    if (self.isNextFilter) {
        return;
    }
    NSUInteger index = [self previousIndex];
    LookupFilter *newFilter = [self makeFilterWithIndex:index];
    [self setupNewFilter:newFilter];
}

- (void)resetFiltersAfterPan {
    [self exchangePreviews];
    NSUInteger index = [self nextIndex];
    LookupFilter *newFilter = [self makeFilterWithIndex:index];
    [self setupNewFilter:newFilter];
}

@end

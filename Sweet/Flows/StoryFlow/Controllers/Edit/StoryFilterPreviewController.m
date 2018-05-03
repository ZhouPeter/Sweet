//
//  StoryFilterPreviewController.m
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "StoryFilterPreviewController.h"
#import "LookupFilter.h"

@interface StoryFilterPreviewController ()

@property (strong, nonatomic) GPUImageOutput *output;
@property (strong, nonatomic) GPUImageView *backgroundPreview;
@property (strong, nonatomic) GPUImageView *foregroundPreview;
@property (strong, nonatomic) NSArray *lookupImages;
@property (assign, nonatomic) BOOL isPanLeft;
@property (assign, nonatomic) BOOL isPanDirectionFixed;
@property (assign, nonatomic) BOOL isNextFilterAvailable;
@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) NSUInteger filterIndex;
@property (assign, nonatomic) BOOL isPhoto;

@end

@implementation StoryFilterPreviewController

- (instancetype)initWithFileURL:(NSURL *)url isPhoto:(BOOL)isPhoto {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.isPhoto = isPhoto;
        if (isPhoto) {
            GPUImagePicture *picture = [[GPUImagePicture alloc] initWithURL:url];
            self.output = picture;
        } else {
            GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:url];
            movie.playAtActualSpeed = YES;
            movie.shouldRepeat = YES;
            self.output = movie;
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
        [(GPUImageMovie *)self.output startProcessing];
    }
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)stopPreview {
    if (!self.isPhoto) {
        [(GPUImageMovie *)self.output endProcessing];
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
            self.isNextFilterAvailable = NO;
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
                    
                    self.isNextFilterAvailable = YES;
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
                    
                    self.isNextFilterAvailable = YES;
                }
            }
        } else {
            if (!self.isNextFilterAvailable) { return; }
            if (self.isPanLeft) { ratio = 1 - ratio; }
            self.foregroundPreview.layer.contentsRect = CGRectMake(0, 0, ratio, 1);
        }
    } else {
        if (!self.isNextFilterAvailable) { return; }
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

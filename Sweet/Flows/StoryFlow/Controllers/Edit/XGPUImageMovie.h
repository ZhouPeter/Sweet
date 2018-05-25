//
//  XGPUImageMovie.h
//  XPro
//
//  Created by Mario Z. on 26/12/2017.
//  Copyright © 2017 Miaozan. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>

@protocol XGPUImageMovieDelegate <NSObject>

- (void)didCompletePlayingMovie;

@end

@interface XGPUImageMovie : GPUImageOutput

@property (readwrite, retain) AVAsset *asset;
@property (readwrite, retain) AVPlayerItem *playerItem;
@property(readwrite, retain) NSURL *url;
@property(readwrite, nonatomic) BOOL runBenchmark;
@property(readwrite, nonatomic) BOOL playAtActualSpeed;
@property(readwrite, nonatomic) BOOL shouldRepeat;
@property(readonly, nonatomic) float progress;
@property (readwrite, nonatomic, assign) id <XGPUImageMovieDelegate>delegate;
@property (readonly, nonatomic) AVAssetReader *assetReader;
@property (readonly, nonatomic) BOOL audioEncodingIsFinished;
@property (readonly, nonatomic) BOOL videoEncodingIsFinished;

@property(readwrite, nonatomic) BOOL playSound;
@property (copy, nonatomic) void (^startProcessingCallback)(void);

- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
- (id)initWithURL:(NSURL *)url;
- (void)yuvConversionSetup;

- (void)enableSynchronizedEncodingUsingMovieWriter:(GPUImageMovieWriter *)movieWriter;
- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput;
- (BOOL)readNextAudioSampleFromOutput:(AVAssetReaderOutput *)readerAudioTrackOutput;
- (void)startProcessing;
- (void)endProcessing;
- (void)cancelProcessing;
- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer;

@end

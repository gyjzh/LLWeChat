//
//  LLGIFImageView.m
//  LLWeChat
//
//  Created by GYJZH on 17/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLGIFImageView.h"
#import "LLUtils.h"
#import "UIImage+EMGIF.h"
@import ImageIO;

@class LLGIFImageView;

@interface LLGIFImageViewManager : NSObject

+ (LLGIFImageViewManager *)sharedManager;

- (void)addGIFView:(LLGIFImageView *)view;

- (void)removeGIFView:(LLGIFImageView *)view;

@end

/**********************************************************************/

@interface LLGIFImageView()

@property (nonatomic, readwrite) NSInteger currentShowIndex;

@property (nonatomic, readwrite) NSInteger totalFrameCount;

@property (nonatomic) CGImageSourceRef gifSourceRef;

@property (nonatomic) dispatch_block_t fetchImageBlock;

@property (nonatomic) dispatch_queue_t dispatch_queue;

@end

@implementation LLGIFImageView {
    float _elapsedTime;
    float _duration;
    
    BOOL _isGifPlaying;
    NSInteger _currentFrameIndex;
    NSMutableArray<NSNumber *> *_allFrameDurations;
    NSInteger _reuseCount;
}

- (dispatch_queue_t)dispatch_queue {
    if (!_dispatch_queue) {
        _dispatch_queue = dispatch_queue_create("GIF_IMAGE_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return _dispatch_queue;
}


- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self stopGIFAnimating];
    
}

- (void)setGifData:(NSData *)gifData {
    NSAssert([NSThread isMainThread], @"应该在主线程设置GIF动画");
    
    if (_gifData != gifData) {
        _gifData = gifData;

        [self stopGIFAnimating];
    }
}

- (void)startGIFAnimating {
    NSAssert([NSThread isMainThread], @"应该在主线程开始GIF动画");

    //FIXME: 为了简单，此处在主线程执行
    if (self.gifData && !self.gifSourceRef) {
        self.gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
    }
        
    if (_gifSourceRef) {
        _elapsedTime = 0;
        _duration = 0;
        _currentFrameIndex = self.startShowIndex;
        _currentShowIndex = 0;
        _fetchImageBlock = nil;
        _totalFrameCount = CGImageSourceGetCount(_gifSourceRef);
        _allFrameDurations = [NSMutableArray arrayWithCapacity:_totalFrameCount];
        
        [[LLGIFImageViewManager sharedManager] addGIFView:self];
        _isGifPlaying = YES;
        
        //如果此时DisplayLink没有启动，则显示为空白。所以需要主动显示一帧
        WEAK_SELF;
        dispatch_async(self.dispatch_queue, ^{
            [weakSelf showFrameWithIndex:weakSelf.startShowIndex reuseCount:_reuseCount];
        });

    }
    
}


- (void)stopGIFAnimating {
    NSAssert([NSThread isMainThread], @"应该在主线程停止GIF动画");
    
    _reuseCount ++;
    [[LLGIFImageViewManager sharedManager] removeGIFView:self];
    _isGifPlaying = NO;
    
    [_allFrameDurations removeAllObjects];
    _elapsedTime = 0;
    _duration = 0;
    _currentFrameIndex = 0;
    self.image = nil;
    _fetchImageBlock = nil;
    _currentShowIndex = 0;
    _totalFrameCount = 0;
    
    @synchronized (self) {
        if (_gifSourceRef) {
            CFRelease(_gifSourceRef);
            _gifSourceRef = nil;
        }
    }
    
}

- (void)play:(double)duration {
    _elapsedTime += duration;
    
    if (_elapsedTime >= _duration) {
        if (_currentFrameIndex % _totalFrameCount == 0) {
            _currentFrameIndex = 0;
            _elapsedTime -= _duration;
            _duration = 0;
        }
        
        if (!_fetchImageBlock) {
            WEAK_SELF;
            NSInteger frameIndex = _currentFrameIndex;
            NSInteger reuseCount = _reuseCount;
            _fetchImageBlock = ^() {
                STRONG_SELF;
                if (reuseCount != strongSelf->_reuseCount) {
                    weakSelf.fetchImageBlock = nil;
                    return;
                }
                
                [weakSelf showFrameWithIndex:frameIndex reuseCount:reuseCount];
                weakSelf.fetchImageBlock = nil;
                
            };
            
            dispatch_async(self.dispatch_queue,_fetchImageBlock);
        }
        
        float frameDuration = 0;
        if (_allFrameDurations.count > _currentFrameIndex) {
            frameDuration = [_allFrameDurations[_currentFrameIndex] floatValue];
        }else {
            frameDuration = [UIImage sd_frameDurationAtIndex:_currentFrameIndex source:self.gifSourceRef];

            [_allFrameDurations addObject:@(frameDuration)];
        }

        _duration += frameDuration;
        _currentFrameIndex ++;
    }

}

- (BOOL)isGIFAnimating{
    return _isGifPlaying;
}

- (void)showFrameWithIndex:(NSInteger)frameIndex reuseCount:(NSInteger)reuseCount {
    CGImageRef ref = NULL;
    
    @synchronized (self) {
        if (self.gifSourceRef) {
           ref = CGImageSourceCreateImageAtIndex(self.gifSourceRef, frameIndex, NULL);
        }
    }

    if (ref) {
        WEAK_SELF;
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONG_SELF;
            if (reuseCount != strongSelf->_reuseCount) {
                CGImageRelease(ref);
                return;
            }
            weakSelf.image = [UIImage imageWithCGImage:ref];
            CGImageRelease(ref);
            weakSelf.currentShowIndex = frameIndex;
        });
    }
    
}

@end


@interface LLGIFImageViewManager ()

@property (nonatomic) CADisplayLink *displayLink;

@property (nonatomic) NSHashTable *gifViewHashTable;

@end

@implementation LLGIFImageViewManager

+ (instancetype)sharedManager {
    static LLGIFImageViewManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[LLGIFImageViewManager alloc] init];
    });
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory | NSHashTableObjectPointerPersonality];
    }
    return self;
}

- (void)play {
    @synchronized (self) {
        for (LLGIFImageView *imageView in _gifViewHashTable) {
            [imageView play:_displayLink.duration];
        }
    }
}

- (void)addGIFView:(LLGIFImageView *)view {
    @synchronized (self) {
        if (![_gifViewHashTable containsObject:view]) {
            [_gifViewHashTable addObject:view];
        }
        
        if (!_displayLink) {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(play)];
            [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }
    }
    
}

- (void)removeGIFView:(LLGIFImageView *)view {
    @synchronized (self) {
        [_gifViewHashTable removeObject:view];
        
        if (_gifViewHashTable.count == 0) {
            [_displayLink invalidate];
            _displayLink = nil;
        }
    }
    
}

@end

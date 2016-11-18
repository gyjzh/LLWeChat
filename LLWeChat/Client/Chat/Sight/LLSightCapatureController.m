//
//  LLSightCapatureController.m
//  LLWeChat
//
//  Created by GYJZH on 13/10/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSightCapatureController.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"

#define INVALID_POSITION_Y -1000

@interface LLSightCapatureController ()<UIGestureRecognizerDelegate>
{
    UIImageView *_sightMainLogo;
    UIImageView *_dragDownImageView;
    UILabel *_hintLabel;
    UIButton *_exitButton;
    UIButton *longPressButton;
    UIPanGestureRecognizer *panRecognizer;
    CGFloat _minY;
    
    CGFloat _beginPointYInWindow;
    
    UIView *_previewView;
}

//@property (nonatomic) LLMovieRecorder *movieRecorder;

@end

@implementation LLSightCapatureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CGFloat _height = THE_GOLDEN_RATIO * SCREEN_HEIGHT;
    _minY = SCREEN_HEIGHT - _height;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _height)];
    [self.view addSubview:_contentView];
    _contentView.backgroundColor = UIColorRGB(23, 24, 25);
    
    _dragDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [_dragDownImageView sizeToFit];
    [_contentView addSubview:_dragDownImageView];
    _dragDownImageView.center = CGPointMake(SCREEN_WIDTH/2, TOP_BAR_HEIGHT/2);
    
    _sightMainLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sight_main_logo"]];
    [_sightMainLogo sizeToFit];
    [_contentView addSubview:_sightMainLogo];
    _sightMainLogo.center = CGPointMake(SCREEN_WIDTH/2, TOP_BAR_HEIGHT + SIGHT_VISUAL_HEIGHT/2);
    
    _hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _hintLabel.textColor = [UIColor whiteColor];
    _hintLabel.font = [UIFont boldSystemFontOfSize:14];
    _hintLabel.text = @"双击放大";
    [_hintLabel sizeToFit];
    _hintLabel.alpha = 0;
    [_contentView addSubview:_hintLabel];
    _hintLabel.center = CGPointMake(SCREEN_WIDTH/2, TOP_BAR_HEIGHT + 280);
    
    _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_exitButton setImage:[UIImage imageNamed:@"icon_sight_close"] forState:UIControlStateNormal];
    [_exitButton sizeToFit];
    [_exitButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_exitButton];
    
    CGRect frame = _exitButton.frame;
    frame.origin.x = SCREEN_WIDTH - 20 - CGRectGetWidth(frame);
    frame.origin.y = CGRectGetHeight(_contentView.frame) - 50;
    _exitButton.frame = frame;
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    panRecognizer.delegate = self;
    [_contentView addGestureRecognizer:panRecognizer];
    
    _beginPointYInWindow = INVALID_POSITION_Y;
    
//    [[LLSightSessionManager sharedManager] setDelegate:self callbackQueue:dispatch_get_main_queue()];
    
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)exit:(id)sender {
    [self.delegate sightCapatureControllerDidCancel:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[LLSightSessionManager sharedManager] startRunning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:DEFAULT_DURATION delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _hintLabel.alpha = 1;
    } completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    if (point.y <= TOP_BAR_HEIGHT + SIGHT_VISUAL_HEIGHT) {
        return YES;
    }
    return NO;
}


- (void)panHandler:(UIPanGestureRecognizer *)pan {
    CGRect frame = self.contentView.frame;
    CGPoint pointInWindow = [pan locationInView:self.view.window];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            if (pointInWindow.y < _minY - 20) {
                return;
            }
            frame.origin.y += [pan translationInView:self.contentView].y;
            if (frame.origin.y <=0 )
                frame.origin.y = 0;
            self.contentView.frame = frame;
            
            [pan setTranslation:CGPointZero inView:self.contentView];
                   break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if (frame.origin.y <= SIGHT_VISUAL_HEIGHT/2) {
                [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                    CGRect frame = self.contentView.frame;
                    frame.origin.y = 0;
                    self.contentView.frame = frame;
                }];
            }else {
                [self exit:nil];
            }
        }
            
        default:
            break;
            
    }

}

- (void)scrollViewPanGestureRecognizerStateChanged:(UIPanGestureRecognizer *)panGestureGecognizer {
    CGRect frame = self.contentView.frame;
    CGPoint pointInWindow = [panGestureGecognizer locationInView:self.view.window];
    
    switch (panGestureGecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _beginPointYInWindow = INVALID_POSITION_Y;
            break;
            
        case UIGestureRecognizerStateChanged: {
            if (pointInWindow.y < _minY - 20) {
                return;
            }

            if (_beginPointYInWindow == INVALID_POSITION_Y) {
                _beginPointYInWindow = pointInWindow.y;
            }
            
            frame.origin.y += pointInWindow.y - _beginPointYInWindow;
            _beginPointYInWindow = pointInWindow.y;
            if (frame.origin.y <=0 )
                frame.origin.y = 0;
            self.contentView.frame = frame;

            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            _beginPointYInWindow = INVALID_POSITION_Y;
            if (frame.origin.y <= SIGHT_VISUAL_HEIGHT/2) {
                [UIView animateWithDuration:DEFAULT_DURATION animations:^{
                    CGRect frame = self.contentView.frame;
                    frame.origin.y = 0;
                    self.contentView.frame = frame;
                }];
            }else {
                [self exit:nil];
            }
            break;
        }
 
        default:
            break;
            
    }
}

#pragma mark - Preview - 

- (void)setupPreviewView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_previewView action:@selector(changeFocusHander:)];
    tap.numberOfTapsRequired = 2;
    
    [_previewView addGestureRecognizer:tap];
}


- (void)changeFocusHander:(UIGestureRecognizer *)tap {
    
}


#pragma mark - Session Manager Delegate -

//- (void)sessionManager:(LLSightSessionManager *)manager recordingDidFailWithError:(NSError *)error {
//    
//}
//
//- (void)sessionManager:(LLSightSessionManager *)sessionManager didStopRunningWithError:(NSError *)error {
//    
//}
//
//- (void)sessionManagerRecordingDidStop:(LLSightSessionManager *)manager {
//    
//}
//
//- (void)sessionManagerRecordingDidStart:(LLSightSessionManager *)manager {
//    
//}
//
//- (void)sessionManagerRecordingWillStop:(LLSightSessionManager *)manager {
//    
//}

@end

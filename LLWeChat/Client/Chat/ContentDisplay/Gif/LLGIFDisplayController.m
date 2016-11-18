//
//  LLGIFDisplayController.m
//  LLWeChat
//
//  Created by GYJZH on 06/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLGIFDisplayController.h"
#import "LLGIFImageView.h"
#import "LLUtils.h"
#import "LLChatManager+MessageExt.h"

#define GIF_WIDTH 100

@interface LLGIFDisplayController ()

@property (nonatomic) LLGIFImageView *gifImageView;

@end

@implementation LLGIFDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _gifImageView = [[LLGIFImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - GIF_WIDTH)/2, 250, GIF_WIDTH, GIF_WIDTH)];
    _gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_gifImageView];
    
    UITapGestureRecognizer *doubleGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleGesture:)];
    doubleGR.numberOfTapsRequired = 2;
    doubleGR.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleGR];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.gifImageView.image) {
        NSData *gifData = [[LLChatManager sharedManager] gifDataForGIFMessageModel:self.messageModel];
        self.gifImageView.gifData = gifData;
        self.gifImageView.startShowIndex = self.messageModel.gifShowIndex;
        [self.gifImageView startGIFAnimating];
    }

}

- (void)handleDoubleGesture:(UIGestureRecognizer *)gesture {
    [UIView animateWithDuration:DEFAULT_DURATION
                     animations:^{
                         CGFloat scaleFactor = CGRectGetWidth(self.gifImageView.frame) == GIF_WIDTH ? 2 : 1;
                         
                         CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                         self.gifImageView.transform = transform;
                     }];
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

@end

//
//  MFMailComposeViewController_LL.m
//  LLWeChat
//
//  Created by GYJZH on 08/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "MFMailComposeViewController_LL.h"

@interface MFMailComposeViewController_LL ()

@end

@implementation MFMailComposeViewController_LL

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

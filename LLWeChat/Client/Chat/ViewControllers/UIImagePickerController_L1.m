//
//  LLSharedImagePickerController.m
//  LLWeChat
//
//  Created by GYJZH on 9/3/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "UIImagePickerController_L1.h"


@interface UIImagePickerController_L1 ()

@end

@implementation UIImagePickerController_L1


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

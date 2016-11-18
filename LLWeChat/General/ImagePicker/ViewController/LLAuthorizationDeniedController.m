//
//  LLAuthorizationDeniedController.m
//  LLWeChat
//
//  Created by GYJZH on 05/11/2016.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLAuthorizationDeniedController.h"
#import "LLUtils.h"
#import "LLImagePickerController.h"

@interface LLAuthorizationDeniedController ()

@property (nonatomic) UILabel *label;

@end

@implementation LLAuthorizationDeniedController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"照片";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf:)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = NAVIGATION_BAR_RIGHT_MARGIN;
    
    self.navigationItem.rightBarButtonItems = @[spaceItem, rightItem];
    
    CGFloat _width = SCREEN_WIDTH * 0.8;
    _label = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - _width)/2, 128, _width, 64)];
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:16];
    _label.textColor = [UIColor blackColor];
    NSString *appName = [LLUtils appName];
    _label.text = PHOTO_AUTHORIZATION_DENIED_TEXT;
    [self.view addSubview:_label];
    
    
}

- (void)dismissSelf:(id)sender {
    LLImagePickerController *picker = (LLImagePickerController *)(self.navigationController);
    [picker.pickerDelegate imagePickerControllerDidCancel:picker];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

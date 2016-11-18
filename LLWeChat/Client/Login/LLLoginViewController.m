//
// Created by GYJZH on 7/17/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import "LLLoginViewController.h"
#import "EMClient.h"
#import "LLUtils.h"
#import "UIKit+LLExt.h"
#import "LLConfig.h"
#import "LLClientManager.h"

@interface LLLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end


@implementation LLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer:tapGesture];

    self.accountTextField.text = [self getLastLoginUsername];
    
    //XXX 为了方便
    self.passwordTextField.text = self.accountTextField.text;

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}


- (void)resignKeyboard:(UITapGestureRecognizer *)tap {
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    }else {
        if (self.loginButton.enabled)
            [self loginButtonPressed:nil];
    }
    
    return YES;
}


- (IBAction)textFieldDidChange:(UITextField *)sender {
    if (self.accountTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        self.loginButton.enabled = YES;
    }else {
        self.loginButton.enabled = NO;
    }
}

#pragma mark - 用户登录

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [self.view endEditing:YES];

    [[LLClientManager sharedManager] loginWithUsername:self.accountTextField.text password:self.passwordTextField.text];
    
}

- (IBAction)registerButtonPressed:(id)sender {
    [self.view endEditing:YES];

    [[LLClientManager sharedManager] registerWithUsername:self.accountTextField.text password:self.passwordTextField.text];
       
}



- (NSString *)getLastLoginUsername {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:LAST_LOGIN_USERNAME_KEY];
}




@end

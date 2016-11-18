//
//  LLMainViewController.m
//  LLWeChat
//
//  Created by GYJZH on 9/9/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMainViewController.h"
#import "LLUtils.h"
#import "LLSDK.h"
#import "LLMessageCacheManager.h"
#import "LLConversationModelManager.h"
#import "LLContactController.h"
#import "LLDiscoveryController.h"

#define TAB_ITEM_NUM 4

@interface LLMainViewController ()<UITabBarDelegate, UINavigationControllerDelegate>

@property (nonatomic) UITabBar *tabBar;

@property (nonatomic) LLViewController *currentViewController;

@end

@implementation LLMainViewController {
    LLViewController *tabBarViewControllers[TAB_ITEM_NUM];
}

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - MAIN_BOTTOM_TABBAR_HEIGHT - NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, MAIN_BOTTOM_TABBAR_HEIGHT)];
    self.tabBar.delegate = self;
    [self setupTabbarItems];
    self.tabBar.selectedItem = self.tabBar.items[0];
    
    self.currentViewController = [self viewControllerForTabbarIndex:0];
    self.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

- (void)setCurrentViewController:(LLViewController *)currentViewController {
    if (_currentViewController == currentViewController)
        return;
    
    _currentViewController = currentViewController;
    [self setViewControllers:@[_currentViewController] animated:NO];
    [_currentViewController.view addSubview:self.tabBar];
}

- (void)setupTabbarItems {
    NSArray *images = @[@"tabbar_mainframe", @"tabbar_contacts", @"tabbar_discover", @"tabbar_me"];
    
    NSArray *selectedImages =  @[@"tabbar_mainframeHL", @"tabbar_contactsHL", @"tabbar_discoverHL", @"tabbar_meHL"];
    
    NSArray *titles = @[@"微信",@"通讯录", @"发现", @"我"];
    
    NSMutableArray<UITabBarItem *> *items = [NSMutableArray array];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIImage *image = [UIImage imageNamed:images[i]];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *imageHL = [UIImage imageNamed:selectedImages[i]];
        imageHL = [imageHL imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item = [[UITabBarItem alloc]
                initWithTitle:titles[i]
                        image:image
                selectedImage:imageHL];
        item.tag = i;
        
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} forState:UIControlStateNormal];
        
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexRGB:@"#68BB1E"]} forState:UIControlStateSelected];
        
        [items addObject:item];
    }
    
    self.tabBar.items = items;

}

- (LLViewController *)viewControllerForTabbarIndex:(NSInteger)index {
    if (tabBarViewControllers[index]) {
        return tabBarViewControllers[index];
    }
    
    LLViewController *viewController;
    switch (index) {
        case 0: {
            viewController = [[LLConversationListController alloc] init];
            break;
        }
        case 1: {
            viewController = [[LLContactController alloc] init];
            break;
        }
        case 2 :{
            viewController = [[LLDiscoveryController alloc] init];
            break;
        }
        case 3: {
            viewController = [[LLUtils mainStoryboard] instantiateViewControllerWithIdentifier:SB_ME_VC_ID];
            break;
        }
            
        default:
            break;
    }
    
    tabBarViewControllers[index] = viewController;
    return viewController;
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    LLViewController *targetVC = [self viewControllerForTabbarIndex:item.tag];
    if (self.currentViewController != targetVC) {
        self.currentViewController = targetVC;
    }
}

- (void)setTabbarBadgeValue:(NSInteger)badge tabbarIndex:(LLMainTabbarIndex)tabbarIndex {
    self.tabBar.items[tabbarIndex].badgeValue = badge > 0 ? [NSString stringWithFormat:@"%ld", (long)badge] : nil;
}


#pragma mark - Navigation -

- (LLChatViewController *)chatViewController {
    if (!_chatViewController) {
        _chatViewController = [[LLUtils mainStoryboard] instantiateViewControllerWithIdentifier:SB_CHAT_VC_ID];
        _chatViewController.hidesBottomBarWhenPushed = YES;
        _chatViewController.view.frame = SCREEN_FRAME;
    }

    return _chatViewController;
}

- (void)chatWithContact:(NSString *)userName {
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[LLChatViewController class]]) {
            return;
        }
    }
    
    LLConversationModel *conversationModel = [[LLChatManager sharedManager]
                        getConversationWithConversationChatter:userName
                                        conversationType:kLLConversationTypeChat];
    
    [[LLMessageCacheManager sharedManager] prepareCacheWhenConversationBegin:conversationModel];
    
    self.chatViewController.conversationModel = conversationModel;
    [self.chatViewController fetchMessageList];
    [self.chatViewController refreshChatControllerForReuse];
    
    _currentViewController = [self viewControllerForTabbarIndex:0];
    [_currentViewController.view addSubview:self.tabBar];
    self.tabBar.selectedItem = self.tabBar.items[0];
    [self setViewControllers:@[_currentViewController, self.chatViewController] animated:YES];
   
}

- (void)chatWithConversationModel:(LLConversationModel *)conversationModel {
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[LLChatViewController class]]) {
            return;
        }
    }

    [[LLMessageCacheManager sharedManager] prepareCacheWhenConversationBegin:conversationModel];
    
    self.chatViewController.conversationModel = conversationModel;
    [self.chatViewController fetchMessageList];
    [self.chatViewController refreshChatControllerForReuse];
    
    [self pushViewController:self.chatViewController animated:YES];
    
}


@end

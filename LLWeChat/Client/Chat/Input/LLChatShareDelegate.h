//
//  LLChatShareDelegate.h
//  LLWeChat
//
//  Created by GYJZH on 8/12/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TAG_Photo 1
#define TAG_Camera 2
#define TAG_Sight 3
#define TAG_VideoCall 4
#define TAG_Redpackage 5
#define TAG_MoneyTransfer 6
#define TAG_Location 6
#define TAG_Favorites 7
#define TAG_Card 8
#define TAG_Wallet 9

@protocol LLChatShareDelegate <NSObject>

- (void)cellWithTagDidTapped:(NSInteger)tag;

@end

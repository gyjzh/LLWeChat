//
// Created by GYJZH on 7/17/16.
// Copyright (c) 2016 GYJZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLColors.h"

#pragma mark - 环信SDK配置 -

#define EASE_MOB_APP_KEY @"1172161124178919#llwechat"

#pragma mark - ID配置 -

//Storyboard中ViewControllerID
#define SB_LOGIN_VC_ID @"LoginViewController"
#define SB_MAIN_VC_ID @"MainViewController"

#define SB_CONVERSATION_VC_ID @"ConversationListController"
#define SB_CONTACT_VC_ID @"ContactController"
#define SB_DISCOVERY_VC_ID @"DiscoveryController"
#define SB_ME_VC_ID @"MeViewController"
#define SB_CHAT_VC_ID @"ChatViewController"

#define SB_CONVERSATION_SEARCH_VC_ID @"ConversationSearchController"

#define EMOTION_COLLECTION_EMOJI_CELL_ID @"EmotionSmallCell"

#define EMOTION_COLLECTION_GIF_CELL_ID @"EmotionBigCell"

#define EMOTION_CONTROLLER_ID @"EmotionController"

#define DEFAULT_TABLE_CELL_ID @"ID"



#pragma mark - UserDefaults Keys - 

#define DOUBLE_TAP_SHOW_TEXT_KEY @"doubleTapShowText"

#define LAST_LOGIN_USERNAME_KEY @"last_login_username"

#define PUSH_OPTIONS_SOUND_KEY @"soundKey"

#define PUSH_OPTIONS_VIBRATE_KEY @"vibrateKey"

#define MESSAGE_EXT_TYPE_KEY @"type"

#define MESSAGE_EXT_GIF_KEY @"GIF"

#define MESSAGE_EXT_LOCATION_KEY @"Location"

#define MESSAGE_EXT_VIDEO_KEY @"Video"

#define CONVERSATION_DRAFT_KEY @"draft"

#pragma mark - 时间配置 -
//默认动画时间，单位秒
#define DEFAULT_DURATION 0.25

//本地消息通知两次响铃之间间隔，单位秒
#define DEFAULT_PLAYSOUND_INTERVAL 2

//聊天界面，需要单独显示消息时间的时间间隔
#define CHAT_CELL_TIME_INTERVEL 2*60

//录音需要的最短时间
#define MIN_RECORD_TIME_REQUIRED 1

//录音允许的最长时间
#define MAX_RECORD_TIME_ALLOWED 60

//聊天模块视频录制的最大时长
#define MAX_VIDEO_DURATION_FOR_CHAT 180


#pragma mark - UI配置 -

//navigationBar右侧按钮距离屏幕边缘的距离
#define NAVIGATION_BAR_RIGHT_MARGIN 5

#define NAVIGATION_BAR_HEIGHT 64

#define MAIN_BOTTOM_TABBAR_HEIGHT 50

#define TABLE_VIEW_CELL_DEFAULT_FONT_SIZE 17

#define TABLE_VIEW_CELL_LEFT_MARGIN 20

#define TABLE_VIEW_CELL_DEFAULT_HEIGHT 44

#define FOOTER_LABEL_FONT_SIZE 14

//聊天界面bubble最宽可以占据屏幕宽度的百分比
#define CHAT_BUBBLE_MAX_WIDTH_FACTOR 0.58

#define CHAT_KEYBOARD_PANEL_HEIGHT 217


#pragma mark - 数量配置 -

//一次从服务器最多获取的消息数
#define MESSAGE_LIMIT_FOR_ONE_FETCH 13


#pragma mark - 通用文字配置 -

//TODO:此处为了简单，没有考虑国际化

#define LOCATION_UNKNOWE_ADDRESS @"[未知位置]"
#define LOCATION_UNKNOWE_NAME @"[未知位置]"

#define LOCATION_EMPTY_ADDRESS @"[位置]"
#define LOCATION_EMPTY_NAME @"[位置]"

#define LOCATION_ERROR_ADDRESS @"[获取地理名称出错]"

#define APP_URL_SCHEME @"ll.gyjzh.wechat"
#define APP_URL_IDENTIFIER @"ll.gyjzh"

#define LOCATION_AUTHORIZATION_DENIED_TEXT @"  无法获取你的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务,并允许微信使用定位服务。"

#define RECORD_AUTHORIZATION_DENIED_TEXT @"请在iPhone的“设置-隐私-麦克风”选项中，允许微信访问你的手机麦克风。"

#define PHOTO_AUTHORIZATION_DENIED_TEXT @"请在iPhone的“设置-隐私-照片”选项中，允许微信访问你的手机相册。"


#pragma mark - 项目风格 -

#define LL_TABLE_VIEW_BACKGROUND_COLOR kLLBackgroundColor_slightGray

//项目聊天Cell统一背景颜色
#define LL_MESSAGE_CELL_BACKGROUND_COLOR kLLBackgroundColor_lightGray

//项目聊天Cell统一字体大小
#define LL_MESSAGE_FONT_SIZE 16

//#define FONT_FOR_NUMBEER @"Helvetica Neue"
//HelveticaNeue-Medium
//PingFangTC-Semibold
//ArialMT
//PingFangHK-Semibold -Regular -Medium
//Helvetica
//Menlo-Regular

#define FONT_FOR_NUMBER @"PingFangTC-Regular"

#pragma mark - 文件目录 -

#define MessageThumbnailDirectory @"MessageThumbnailDir/"


@interface LLConfig : NSObject



@end

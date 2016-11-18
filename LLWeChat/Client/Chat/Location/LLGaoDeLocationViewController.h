//
//  LLGaoDeLocationViewController.h
//  LLWeChat
//
//  Created by GYJZH on 8/22/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@class LLGaoDeLocationViewController;
@class LLMessageModel;
@protocol LLLocationViewDelegate <NSObject>
@optional

-(LLMessageModel *)didFinishWithLocationLatitude:(double)latitude
                           longitude:(double)longitude
                                name:(NSString *)name
                             address:(NSString *)address
                           zoomLevel:(double)zoomLevel
                            snapshot:(UIImage *)snapshot;

- (void)didCancelLocationViewController:(LLGaoDeLocationViewController *)locationViewController;

//地图截图完成
- (void)asyncTakeCenterSnapshotDidComplete:(UIImage *)resultImage forMessageModel:(LLMessageModel *)messageModel;

@end



@interface LLGaoDeLocationViewController : UIViewController

@property (nonatomic, weak) id<LLLocationViewDelegate> delegate;

- (void)didRowWithModelSelected:(AMapPOI *)poiModel;

@end
